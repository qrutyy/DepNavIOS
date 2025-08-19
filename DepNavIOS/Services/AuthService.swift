//
//  AuthService.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 19.08.2025.
//

import Foundation

struct AuthService {
	let api = APIClient()
	struct AuthResponse: Decodable { let token: String }

	func auth(deviceName: String, userUUID: String, deviceModel: String, priorityMode: String, mapCode: String) async throws -> String {
		struct Payload: Encodable {
			let deviceName: String
			let userUUID: String
			let deviceModel: String
			let priorityMode: String
			let mapCode: String
		}
		let payload = Payload(deviceName: deviceName, userUUID: userUUID, deviceModel: deviceModel, priorityMode: priorityMode, mapCode: mapCode)
		let body = try JSONEncoder().encode(payload)
		let resp: AuthResponse = try await api.request("/auth", method: "POST", body: body)
        print(resp.token)
		return resp.token
	}
}
