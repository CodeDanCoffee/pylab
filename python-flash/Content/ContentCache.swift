//
//  ContentCache.swift
//  python-flash
//
//  On-disk cache for downloaded content, with atomic all-or-nothing commits.
//

import Foundation

/// Persists downloaded content to `Application Support/Content/live/` so later launches
/// load instantly without re-downloading. Application Support (not Caches) is used because
/// once fetched this content is the app's primary runtime data and must not be purged under
/// disk pressure; the directory is excluded from iCloud backup since it is re-downloadable.
struct ContentCache {

    /// Canonical on-disk filenames, matched to the in-app resource names.
    static let categoriesFile = "Category.json"
    static let cardgroupsFile = "CardGroup.json"
    static let cardsFile = "Card.json"

    private let fm = FileManager.default

    private var root: URL {
        let base = try! fm.url(for: .applicationSupportDirectory,
                               in: .userDomainMask, appropriateFor: nil, create: true)
        return base.appendingPathComponent("Content", isDirectory: true)
    }

    private var liveDir: URL { root.appendingPathComponent("live", isDirectory: true) }

    private func liveFile(_ name: String) -> URL { liveDir.appendingPathComponent(name) }

    // MARK: - Read

    /// Returns the committed content, or `nil` if nothing is cached or any file fails to
    /// decode (corruption). A `nil` return is the caller's cue to fall back to the bundle.
    func readLive() -> ContentBundle? {
        guard
            let categories: [Category]  = try? decode(Self.categoriesFile),
            let cardgroups: [CardGroup] = try? decode(Self.cardgroupsFile),
            let cards:      [Card]      = try? decode(Self.cardsFile)
        else { return nil }
        return ContentBundle(categories: categories, cardgroups: cardgroups, cards: cards)
    }

    private func decode<T: Decodable>(_ name: String) throws -> T {
        let data = try Data(contentsOf: liveFile(name))
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Write (atomic, all-or-nothing)

    /// Writes the staged files to a temporary directory, then atomically swaps it into
    /// place as the new `live` directory. A failure at any point leaves the previous
    /// `live` directory untouched, so a half-finished update can never be observed.
    /// `staged` maps a canonical filename (see the static `*File` constants) to its bytes.
    func commit(_ staged: [String: Data]) throws {
        try fm.createDirectory(at: root, withIntermediateDirectories: true)

        let staging = root.appendingPathComponent("staging-\(UUID().uuidString)", isDirectory: true)
        try fm.createDirectory(at: staging, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: staging) } // no-op once moved into place

        for (name, data) in staged {
            try data.write(to: staging.appendingPathComponent(name), options: .atomic)
        }

        if fm.fileExists(atPath: liveDir.path) {
            try fm.removeItem(at: liveDir)
        }
        try fm.moveItem(at: staging, to: liveDir)
        excludeFromBackup(liveDir)
    }

    private func excludeFromBackup(_ url: URL) {
        var url = url
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try? url.setResourceValues(values)
    }
}
