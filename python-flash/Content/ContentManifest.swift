//
//  ContentManifest.swift
//  python-flash
//
//  Codable model for the remote `manifest.json`.
//

import Foundation

/// The remote contract. Example `manifest.json`:
///
///     {
///       "version": 3,
///       "minAppVersion": 1,
///       "files": {
///         "categories": "v3/Category.json",
///         "cardgroups": "v3/CardGroup.json",
///         "cards":      "v3/Card.json"
///       }
///     }
///
/// `files` values are paths **relative** to `AppConfig.contentBaseURL`, which keeps the
/// manifest host-agnostic. Publishing an update = upload new JSON under a fresh `vN/`
/// folder, point `files` at it, and bump `version`.
struct ContentManifest: Codable, Equatable {
    let version: Int
    let minAppVersion: Int
    let files: Files

    struct Files: Codable, Equatable {
        let categories: String
        let cardgroups: String
        let cards: String
    }
}
