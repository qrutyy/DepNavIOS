//
//  MapDataService.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import CoreGraphics
import Foundation

protocol MapDataServiceProtocol {
    func loadMapData(for department: String) async throws -> MapDescription
}

class MapDataService: MapDataServiceProtocol {
    func loadMapData(for department: String) async throws -> MapDescription {
        guard let url = Bundle.main.url(
            forResource: department,
            withExtension: "json",
            subdirectory: "Maps/\(department)"
        ) else {
            throw MapDataError.fileNotFound(department)
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(MapDescription.self, from: data)
            // ИЗМЕНЕНИЕ: Просто возвращаем результат.
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
            return "Файл карты для \(department) не найден"
        case let .decodingError(error):
            return "Ошибка чтения данных карты: \(error.localizedDescription)"
        case let .departmentNotFound(department):
            return "Данные для \(department) не загружены"
        case let .markerNotFound(query):
            return "Маркер '\(query)' не найден"
        }
    }
}
