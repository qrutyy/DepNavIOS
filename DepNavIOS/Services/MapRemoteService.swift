//
//  MapRemoteService.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 19.08.2025.
//

import Foundation
import ZIPFoundation

@MainActor
final class SessionStore: ObservableObject {
    @Published var token: String?
    @Published var mapCode: String?
}

struct MapRemoteService {
    let api = APIClient()
    let session: SessionStore
    struct TextResponse: Decodable { let text: String }

    func fetchMapText() async throws -> String {
        guard let token = await session.token else { throw NSError(domain: "Session", code: 401) }
        let resp: TextResponse = try await api.request("/data", headers: ["Authorization": "Bearer \(token)"])
        return resp.text
    }

    func directoryTree(at url: URL, prefix: String = "") -> String {
        var result = ""
        let fileManager = FileManager.default

        guard let contents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return result
        }

        for (index, item) in contents.enumerated() {
            let isLast = index == contents.count - 1
            let branch = isLast ? "└── " : "├── "
            result += prefix + branch + item.lastPathComponent + "\n"

            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: item.path, isDirectory: &isDir), isDir.boolValue {
                let newPrefix = prefix + (isLast ? "    " : "│   ")
                result += directoryTree(at: item, prefix: newPrefix)
            }
        }
        return result
    }

    func downloadMap(url: URL) async throws -> URL {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(await session.token ?? "")", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)

        let tempDir = FileManager.default.temporaryDirectory
        let zipURL = tempDir.appendingPathComponent("map.zip")
        try data.write(to: zipURL)
        return zipURL
    }

    func checkMapExists(mapCode: String) async -> Bool {
        struct ExistsResponse: Decodable { let exists: Bool }
        do {
            let resp: ExistsResponse = try await api.request("/maps/exists?map_code=\(mapCode)")
            return resp.exists
        } catch {
            // If the API returns 404 or any error, treat as not found
            print("Error checking map existence: \(error)")
            return false
        }
    }

    // Remove extractMap and any temp directory logic for maps. Extraction is now handled in MapViewModel to Documents/Maps/<mapCode>/
}
