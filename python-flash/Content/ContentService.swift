//
//  ContentService.swift
//  python-flash
//
//  Networking layer: fetches the manifest and content files over HTTPS.
//

import Foundation

enum ContentError: Error {
    case badResponse(Int)
}

/// Thin async/await wrapper over `URLSession`. Host-agnostic: every request is resolved
/// against `AppConfig.contentBaseURL`, so changing the host needs no change here.
struct ContentService {

    private let session: URLSession = .shared

    /// Fetches and decodes the version manifest. Bypasses the URL cache so a version
    /// check is never answered with a stale manifest.
    func fetchManifest() async throws -> ContentManifest {
        let url = AppConfig.contentBaseURL.appendingPathComponent(AppConfig.manifestFileName)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        request.timeoutInterval = 15
        let (data, response) = try await session.data(for: request)
        try Self.checkOK(response)
        return try JSONDecoder().decode(ContentManifest.self, from: data)
    }

    /// Downloads a single content file (path relative to the base URL) and returns its
    /// raw bytes. Decoding/validation is the caller's responsibility so it can validate
    /// all files before committing any of them.
    func fetchFile(_ relativePath: String) async throws -> Data {
        let url = AppConfig.contentBaseURL.appendingPathComponent(relativePath)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        request.timeoutInterval = 30
        let (data, response) = try await session.data(for: request)
        try Self.checkOK(response)
        return data
    }

    private static func checkOK(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { throw ContentError.badResponse(-1) }
        guard 200..<300 ~= http.statusCode else { throw ContentError.badResponse(http.statusCode) }
    }
}
