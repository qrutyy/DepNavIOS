//
//  MapViewModel.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 23.06.2025.
//

import Combine
import CoreGraphics
import Foundation
import SwiftUI

@MainActor
class MapViewModel: ObservableObject {
    // MARK: - Published Properties for UI State

    @Published var selectedFloor: Int = 1
    @Published var selectedDepartment: String = "spbu-pf"
    @Published var markerCoordinate: CGPoint?
    @Published var searchQuery: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedSearchResult: InternalMarkerModel?
    @Published var selectedMarker: String = "" // from map choose
    @Published var selectedMapType: String = "" // just a plug for now. will be a part of the custom map import system
    @Published var mapControl: MapControlModel = .init()

    @Published var dbViewModel = DatabaseViewModel()

    @Published var searchResults: [InternalMarkerModel] = []

    // MARK: - Services and Dependencies

    private let mapDataService: MapDataService

    private var loadedMapDescriptions: [String: MapDescription] = [:]

    private var cancellables = Set<AnyCancellable>()

    @ObservedObject var languageManager = LanguageManagerModel.shared

    init(mapDataService: MapDataService = MapDataService()) {
        self.mapDataService = mapDataService

        $selectedDepartment
            .dropFirst() // чтобы не сработало на дефолтном значении
            .sink { [weak self] _ in
                Task {
                    await self?.loadMapData()
                }
            }
            .store(in: &cancellables)

        dbViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Map Management

    func loadMapData() async {
        if loadedMapDescriptions[selectedDepartment] != nil {
            print("Map for \(selectedDepartment) already loaded.")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let mapDescription = try await mapDataService.loadMapData(for: selectedDepartment)
            if mapDescription.floors.isEmpty || mapDescription.floorWidth <= 0 || mapDescription.floorHeight <= 0 || mapDescription.internalName.isEmpty {
                errorMessage = "MapDescription has unexpected properties"
            }
            loadedMapDescriptions[selectedDepartment] = mapDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func preloadAllDepartments() async {
        let departments = ["spbu-mm", "spbu-pf"]
        for dep in departments where loadedMapDescriptions[dep] == nil {
            do {
                let mapDescription = try await mapDataService.loadMapData(for: dep)
                loadedMapDescriptions[dep] = mapDescription
            } catch {
                print("Failed to load map for \(dep): \(error)")
            }
        }
    }

    func changeFloor(_ floor: Int) {
        selectedFloor = floor
        clearMarker()
    }

    func changeDepartment(_ department: String) {
        selectedDepartment = department
        Task {
            await loadMapData()
        }
    }

    // MARK: - Search Functionality

    func updateSearchResults() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }

        let allMarkers = getAllMarkersForCurrentDepartment()
        let query = searchQuery.lowercased()

        let filteredMarkers = allMarkers.filter { markerData in
            let titleMatch = (markerData.marker.ru.title?.lowercased().hasPrefix(query) ?? false) ||
                (markerData.marker.en.title?.lowercased().hasPrefix(query) ?? false)
            let typeMatch = markerData.marker.type.displayName.lowercased().hasPrefix(query)
            let descriptionMatch = (markerData.marker.ru.description?.lowercased().hasPrefix(query) ?? false) ||
                (markerData.marker.en.description?.lowercased().hasPrefix(query) ?? false)
            return titleMatch || typeMatch || descriptionMatch
        }

        searchResults = filteredMarkers
    }

    func commitSearch() {
        updateSearchResults() // force
        if let topResult = searchResults.first {
            selectSearchResult(topResult)
        } else {
            let failedSearchItem = MapObjectModel(
                id: nil,
                floor: nil,
                department: selectedDepartment,
                objectTitle: searchQuery,
                objectDescription: "Not found",
                objectTypeName: nil,
                objectLocation: "Not found"
            )
            dbViewModel.addHistoryItem(failedSearchItem)
            errorMessage = "Object with id '\(searchQuery)' wasn't found."
        }
    }

    func selectSearchResult(_ marker: InternalMarkerModel) {
        selectedFloor = marker.floor
        markerCoordinate = marker.coordinate
        selectedSearchResult = marker
        selectedMarker = marker.title
        selectedDepartment = marker.department
        searchQuery = ""
        searchResults = []
        dbViewModel.addHistoryItem(marker, department: selectedDepartment)
    }

    func clearSelectedSearchResult() {
        selectedSearchResult = nil
        // Возможно, вы захотите сбросить и маркер на карте
        // markerCoordinate = nil
    }

    func selectMarkerOnMap(markerID: String) {
        searchQuery = markerID
        updateSearchResults()

        if let topResult = searchResults.first { // we are sure that this marker is present
            selectSearchResult(topResult)
        } else {
            print("selectMarkerOnMap: Marker not found")
        }
    }

    func getSelectedMarker() -> InternalMarkerModel? {
        // If we have a selected marker, try to rehydrate it using current map data
        // for up-to-date localization. If map data isn't ready yet, return the cached
        // selection so UI can still present the marker section immediately.
        guard let selected = selectedSearchResult else { return nil }

        guard let mapDescription = currentMapDescription else {
            return selected
        }

        // Prefer matching by stable id, fall back to title/location if needed
        for floorData in mapDescription.floors {
            if let markerData = floorData.markers.first(where: { $0.id == selected.id }) {
                return InternalMarkerModel(
                    id: markerData.id,
                    title: (languageManager.currentLanguage == .en ? markerData.en.title : markerData.ru.title) ?? "",
                    description: (languageManager.currentLanguage == .en ? markerData.en.description : markerData.ru.description) ?? "",
                    location: (languageManager.currentLanguage == .en ? markerData.en.location : markerData.ru.location) ?? "",
                    floor: floorData.floor,
                    coordinate: markerData.coordinate,
                    type: markerData.type,
                    marker: markerData,
                    department: selectedDepartment
                )
            }
        }

        // Fallback: return previously selected
        return selected
    }

    func isMarkerInFavorites(markerID: String) -> Bool {
        dbViewModel.favoriteItems.contains(where: { $0.objectTitle == markerID })
    }

    func addSelectedMarkerToDB(marker: InternalMarkerModel) {
        dbViewModel.addFavoritesItem(marker, department: selectedDepartment)
        // dbViewModel.addHistoryItem(selectedMarker, department: selectedDepartment)
    }

    func selectObjectOnMap(_ item: MapObjectModel) {
        let fullMarker = item.toInternalMarkerModel(mapDescription: getMapDescriptionByDepartment(department: item.department))
        if fullMarker == nil {
            print("MapViewModel: Internal error...")
        } else {
            selectSearchResult(fullMarker!)
        }
    }

    func selectHistoryItem(_ item: MapObjectModel) {
        let fullMarker = item.toInternalMarkerModel(mapDescription: getMapDescriptionByDepartment(department: item.department))
        if fullMarker == nil {
            print("MapViewModel: Internal error...")
        } else {
            if item.department != selectedDepartment {
                selectedDepartment = item.department
            }
            selectSearchResult(fullMarker!)
        }
    }

    var availableFloors: [Int] {
        guard let description = currentMapDescription else {
            return []
        }

        return description.floors.map(\.floor).sorted()
    }

    func removeFavoriteItem(_ item: MapObjectModel) {
        dbViewModel.deleteFavoriteItem(id: item.id)
    }

    var currentMapDescription: MapDescription? {
        loadedMapDescriptions[selectedDepartment]
    }

    func getMapDescriptionByDepartment(department: String) -> MapDescription? {
        loadedMapDescriptions[department] ?? nil
    }

    // MARK: - Map Asset URL

    var currentMapSVGURL: URL? {
        Bundle.main.url(
            forResource: "floor\(selectedFloor)",
            withExtension: "svg",
            subdirectory: "Maps/\(selectedDepartment)"
        )
    }

    func clearMarker() {
        markerCoordinate = nil
        searchQuery = ""
        searchResults = []
    }

    func clearSelectedMarker() {
        selectedMarker = ""
        selectedSearchResult = nil
        markerCoordinate = nil
    }

    private func getAllMarkersForCurrentDepartment() -> [InternalMarkerModel] {
        guard let mapDescription = currentMapDescription else { return [] }
        return mapDescription.floors.flatMap { floorData in
            floorData.markers.map { marker in
                InternalMarkerModel(id: marker.id, title: (languageManager.currentLanguage == .en ? marker.en.title : marker.ru.title) ?? "",
                                    description: (languageManager.currentLanguage == .en ? marker.en.description : marker.ru.description) ?? "",
                                    location: (languageManager.currentLanguage == .en ? marker.en.location : marker.ru.location) ?? "",
                                    floor: floorData.floor, coordinate: marker.coordinate, type: marker.type, marker: marker, department: selectedDepartment)
            }
        }
    }
}
