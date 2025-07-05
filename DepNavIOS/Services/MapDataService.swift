//
//  MapDataService.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import CoreGraphics
import Foundation

protocol MapDataServiceProtocol {
    func loadMapData(for department: String) async throws
    func getMapDescription(for department: String) -> MapDescription?
    func findMarker(query: String, department: String) async throws -> MarkerWithFloor
}

struct MarkerWithFloor {
    let marker: Marker
    let floor: Int
    let title: String
    let description: String
    let type: MarkerType
    let coordinate: CGPoint
}

class MapDataService: MapDataServiceProtocol {
    private var mapDescriptions: [String: MapDescription] = [:]

    func loadMapData(for department: String) async throws {
        // Check if already loaded
        if mapDescriptions[department] != nil {
            return
        }

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
            mapDescriptions[decodedData.internalName] = decodedData
        } catch {
            throw MapDataError.decodingError(error)
        }
    }

    func getMapDescription(for department: String) -> MapDescription? {
        return mapDescriptions[department]
    }

    func findMarker(query: String, department: String) async throws -> MarkerWithFloor {
        guard let mapDescription = mapDescriptions[department] else {
            throw MapDataError.departmentNotFound(department)
        }

        let searchQuery = query.lowercased()

        for floorData in mapDescription.floors {
            if let foundMarker = floorData.markers.first(where: { marker in
                let titleMatch = marker.ru.title?.lowercased().contains(searchQuery) == true ||
                    marker.en.title?.lowercased().contains(searchQuery) == true
                let typeMatch = marker.type.displayName.lowercased().contains(searchQuery) == true
                let descriptionMatch = marker.ru.description?.lowercased().contains(searchQuery) == true

                return titleMatch || typeMatch || descriptionMatch
            }) {
                return MarkerWithFloor(
                    marker: foundMarker,
                    floor: floorData.floor,
                    title: foundMarker.ru.title ?? foundMarker.en.title ?? "",
                    description: foundMarker.ru.description ?? foundMarker.en.description ?? "",
                    type: foundMarker.type,
                    coordinate: foundMarker.coordinate
                )
            }
        }

        throw MapDataError.markerNotFound(query)
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
