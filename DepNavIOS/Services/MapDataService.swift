//
//  MapDataService.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 23.06.2025.
//

import CoreGraphics
import Foundation

protocol MapDataServiceProtocol {
    func loadMapData(for department: String) async throws -> MapDescription
}

class MapDataService: MapDataServiceProtocol {
    func loadMapData(for department: String) async throws -> MapDescription {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let jsonURL = docs.appendingPathComponent("Maps").appendingPathComponent(department).appendingPathComponent("\(department).json")
        guard FileManager.default.fileExists(atPath: jsonURL.path) else {
            throw MapDataError.fileNotFound(department)
        }
        do {
            let data = try Data(contentsOf: jsonURL)
            let decodedData = try JSONDecoder().decode(MapDescription.self, from: data)
            return decodedData
        } catch {
            throw MapDataError.decodingError(error)
        }
    }
}

enum MapDataError: LocalizedError {
    case fileNotFound(String)
    case decodingError(Error)
    case departmentNotFound(String)
    case markerNotFound(String)

    var errorDescription: String? {
        switch self {
        case let .fileNotFound(department):
            "File fot the \(department) wasn't found"
        case let .decodingError(error):
            "Decoding error at loading map data: \(error.localizedDescription)"
        case let .departmentNotFound(department):
            "\(department) map wasn't found"
        case let .markerNotFound(query):
            "Marker with id '\(query)' wasn't found"
        }
    }
}
