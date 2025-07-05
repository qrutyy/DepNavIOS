//
//  MapViewModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import CoreGraphics
import Foundation
import SwiftUI

/// Main ViewModel for handling map states and navigation logic.
///
/// - Parameters:
/// - selectedFloor: Stores current floor, picked by FloorSelectionView or changed by MarkerSearch.
/// - selectedDepartment: *Almost* the same, but with department.
/// - markerCoordinate: Loaded/Found marker coordinate
/// - searchQuery: Search string
/// - isLoading: Map state
/// - errorMessage: Error message string
@MainActor
class MapViewModel: ObservableObject {
    @Published var selectedFloor: Int = 1
    @Published var selectedDepartment: String = "spbu-mm"
    @Published var markerCoordinate: CGPoint?
    @Published var searchQuery: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let mapDataService: MapDataService
    private let databaseService: DatabaseService
    let coordinateLoader: CoordinateLoader

    init(mapDataService: MapDataService = MapDataService(),
         databaseService: DatabaseService = DatabaseService()) {
        self.mapDataService = mapDataService
        self.databaseService = databaseService
        coordinateLoader = CoordinateLoader()
    }

    // MARK: - Map Management

    func loadMapData() async {
        isLoading = true
        do {
            try await mapDataService.loadMapData(for: selectedDepartment)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func changeFloor(_ floor: Int) {
        selectedFloor = floor
        markerCoordinate = nil
        searchQuery = ""
    }

    func changeDepartment(_ department: String) {
        selectedDepartment = department
        Task {
            await loadMapData()
        }
    }

    // MARK: - Search Functionality

    func searchMarker() async {
        guard !searchQuery.isEmpty else { return }

        isLoading = true
        do {
            let marker = try await mapDataService.findMarker(
                query: searchQuery,
                department: selectedDepartment
            )

            markerCoordinate = marker.coordinate
            selectedFloor = marker.floor

            // Save to history
            let historyItem = HistoryModel(
                id: 0, // Will be set by database
                floor: marker.floor,
                department: selectedDepartment,
                objectTitle: marker.title,
                objectDescription: marker.description,
                objectTypeName: marker.type.displayName
            )

            await databaseService.addHistoryItem(historyItem)
            isLoading = false

        } catch {
            errorMessage = "Маркер не найден"
            isLoading = false
        }
    }

    func clearMarker() {
        markerCoordinate = nil
        searchQuery = ""
    }

    // MARK: - Computed Properties

    var mapDescription: MapDescription? {
        mapDataService.getMapDescription(for: selectedDepartment)
    }

    var currentFloorMarkers: [Marker] {
        guard let mapDescription = mapDescription else { return [] }
        return mapDescription.floors.first { $0.floor == selectedFloor }?.markers ?? []
    }

    var searchResults: [Marker] {
        guard !searchQuery.isEmpty else { return [] }
        let query = searchQuery.lowercased()

        return currentFloorMarkers.filter { marker in
            marker.ru.title?.lowercased().contains(query) == true ||
                marker.en.title?.lowercased().contains(query) == true ||
                marker.type.displayName.lowercased().contains(query) == true ||
                marker.ru.description?.lowercased().contains(query) == true
        }
    }
}
