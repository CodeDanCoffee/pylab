//
//  BookmarkStorage.swift
//  python-flash
//
//  Created by Quantmis on 29/08/2023.
//

import SwiftUI

class BookmarkStorage: ObservableObject {
    @AppStorage("bookmarks") private var bookmarksData: Data = Data()

    @Published private var internalBookmarks: [Card] = []

    var bookmarks: [Card] {
        get {
            return internalBookmarks
        }
        set {
            internalBookmarks = newValue
            saveBookmarks()
        }
    }

    init() {
        // Initialize internalBookmarks by decoding data from @AppStorage or use an empty array if no data is found.
        if let decodedData = try? JSONDecoder().decode([Card].self, from: bookmarksData) {
            self.internalBookmarks = decodedData
        } else {
            self.internalBookmarks = []
        }
    }

    private func saveBookmarks() {
        // Encode and save bookmarks to @AppStorage whenever they change.
        if let encodedData = try? JSONEncoder().encode(internalBookmarks) {
            bookmarksData = encodedData
        }
    }
}
