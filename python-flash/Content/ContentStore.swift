//
//  ContentStore.swift
//  python-flash
//
//  Single source of truth for learning content. Replaces the former global vars
//  (`categories` / `cardgroups` / `cards`) in ModelData.swift.
//

import SwiftUI

/// Owns the content the app renders and orchestrates the load → check → update flow.
///
/// Launch sequence (`start()`):
///  1. Apply cached content if present, else the bundled fallback, and become `.ready`
///     immediately so the UI is never blocked on the network.
///  2. In the background, fetch the remote manifest. If a newer version exists, show the
///     `.updating` state, download + validate + atomically commit all files, bump the
///     stored version, and publish. Any failure leaves the current content intact.
@MainActor
final class ContentStore: ObservableObject {

    enum State: Equatable {
        case loading
        case updating(progress: Double)
        case ready
        case failed(String)
    }

    @Published private(set) var categories: [Category] = []
    @Published private(set) var cardgroups: [CardGroup] = []
    @Published private(set) var cards: [Card] = []
    @Published private(set) var state: State = .loading

    /// Locally-installed content version. `0` means "bundled baseline only" so any
    /// remote `version > 0` triggers a first update.
    @AppStorage("contentVersion") private var localVersion: Int = 0

    private let cache = ContentCache()
    private let service = ContentService()

    /// Call once at app launch.
    func start() async {
        // 1) Instant content: committed cache, else bundled fallback.
        if let cached = cache.readLive() {
            apply(cached)
        } else {
            apply(loadFromBundle())
        }
        state = .ready

        // 2) Background: update if the host has a newer version.
        await checkForUpdate()
    }

    private func checkForUpdate() async {
        do {
            let manifest = try await service.fetchManifest()

            // Skip content that needs a newer app than this build (schema guard).
            guard manifest.minAppVersion <= AppConfig.appVersion else { return }
            // Up to date, or host is serving an older manifest — ignore (no downgrade).
            guard manifest.version > localVersion else { return }

            state = .updating(progress: 0)

            // Download all files concurrently (total payload is small).
            async let categoriesData = service.fetchFile(manifest.files.categories)
            async let cardgroupsData = service.fetchFile(manifest.files.cardgroups)
            async let cardsData      = service.fetchFile(manifest.files.cards)
            let (catData, grpData, crdData) = try await (categoriesData, cardgroupsData, cardsData)
            state = .updating(progress: 0.7)

            // Validate by decoding BEFORE committing — a bad payload aborts here.
            let categories = try JSONDecoder().decode([Category].self,  from: catData)
            let cardgroups = try JSONDecoder().decode([CardGroup].self, from: grpData)
            let cards      = try JSONDecoder().decode([Card].self,      from: crdData)

            // Atomic, all-or-nothing commit, then bump version, then publish.
            try cache.commit([
                ContentCache.categoriesFile: catData,
                ContentCache.cardgroupsFile: grpData,
                ContentCache.cardsFile:      crdData,
            ])
            localVersion = manifest.version
            apply(ContentBundle(categories: categories, cardgroups: cardgroups, cards: cards))

            state = .updating(progress: 1.0)
            state = .ready
        } catch {
            // Offline / 404 / bad JSON: keep whatever content we already applied.
            if state != .ready { state = .ready }
        }
    }

    // MARK: - Helpers

    private func loadFromBundle() -> ContentBundle {
        ContentBundle(
            categories: load(ContentCache.categoriesFile),
            cardgroups: load(ContentCache.cardgroupsFile),
            cards:      load(ContentCache.cardsFile)
        )
    }

    private func apply(_ bundle: ContentBundle) {
        categories = bundle.categories
        cardgroups = bundle.cardgroups
        cards = bundle.cards
    }

    /// Preview/testing store seeded from the bundled JSON.
    static var preview: ContentStore {
        let store = ContentStore()
        store.apply(store.loadFromBundle())
        store.state = .ready
        return store
    }
}
