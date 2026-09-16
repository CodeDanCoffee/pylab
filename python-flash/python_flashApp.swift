//
//  python_flashApp.swift
//  python-flash
//
//  Created by Quantmis on 28/08/2023.
//

import SwiftUI
import RevenueCat

@main
struct python_flashApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("hasShownOnboarding") var hasShownOnboarding = false
    @StateObject var userViewModel = UserViewModel()
    @StateObject var contentStore = ContentStore()

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_XNVggFPcQluWQYIbSHtINSwnJuF")
    }
    var body: some Scene {

        WindowGroup {
            RootGate()
                .environmentObject(userViewModel)
                .environmentObject(contentStore)
                .task { await contentStore.start() }
        }
    }
}

/// Gates the app on the content load state: shows the game-style loading/updating screen
/// while content is loading or downloading, and the main UI once content is ready.
private struct RootGate: View {
    @EnvironmentObject var contentStore: ContentStore

    var body: some View {
        switch contentStore.state {
        case .loading:
            ContentLoadingView(progress: nil)
        case .updating(let progress):
            ContentLoadingView(progress: progress)
        case .failed:
            // Content is still usable from cache/bundle, so just proceed to the app.
            LayoutView()
        case .ready:
            LayoutView()
        }
    }
}
