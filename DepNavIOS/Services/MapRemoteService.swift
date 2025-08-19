//
//  AuthService.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 19.08.2025.
//

import Foundation

final class SessionStore: ObservableObject {
	@Published var token: String?
	@Published var mapCode: String?
}

struct MapRemoteService {
	let api = APIClient()
	let session: SessionStore
	struct TextResponse: Decodable { let text: String }

	func fetchMapText() async throws -> String {
		guard let token = session.token else { throw NSError(domain: "Session", code: 401) }
		let resp: TextResponse = try await api.request("/data", headers: ["Authorization": "Bearer \(token)"])
		return resp.text
	}
}
