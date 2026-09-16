//
//  AppConfig.swift
//  python-flash
//
//  Host-agnostic configuration for remote learning content.
//

import Foundation

/// Single place that ties the app to a content host. Repoint to S3 / CloudFront /
/// Cloudflare R2 / GitHub raw / Firebase Storage by changing only `contentBaseURL`.
enum AppConfig {

    /// Base URL the manifest and content files are resolved against.
    /// The trailing slash matters — `appendingPathComponent` resolves relative paths under it.
    static let contentBaseURL = URL(string: "https://cdn.example.com/pylab/")!

    /// Name of the version manifest at the base URL.
    static let manifestFileName = "manifest.json"

    /// Content-schema version this build understands. Bump whenever the
    /// `Card` / `CardGroup` / `Category` model structs change shape, then set the
    /// host manifest's `minAppVersion` to match so older apps skip incompatible content.
    static let appVersion = 1
}
