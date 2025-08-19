//
//  APIClient.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 19.08.2025.
//

import Foundation

struct APIClient {
	let baseURL = URL(string: "http://127.0.0.1:8080")!

	func request<T: Decodable>(_ path: String,
							   method: String = "GET",
							   headers: [String: String] = [:],
							   body: Data? = nil,
							   decoder: JSONDecoder = JSONDecoder()) async throws -> T {
		var url = baseURL
		url.append(path: path)

		var req = URLRequest(url: url)
		req.httpMethod = method
		req.httpBody = body
		for (k, v) in headers { req.setValue(v, forHTTPHeaderField: k) }
		if body != nil { req.setValue("application/json", forHTTPHeaderField: "Content-Type") }

		let (data, resp) = try await URLSession.shared.data(for: req)
		if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
			let text = String(data: data, encoding: .utf8) ?? ""
			throw NSError(domain: "APIError", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: text])
		}
		return try decoder.decode(T.self, from: data)
	}
}
