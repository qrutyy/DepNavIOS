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
    @Published var selectedDepartment: String = "spbu-mm"
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
    
    @Published var sessionStore: SessionStore?
    
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
    
    // MARK: - Unified Map Storage
    
    private let mapsDirectory: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("Maps")
    }()
    
    private var hasCopiedBundledMaps: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCopiedBundledMaps") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCopiedBundledMaps") }
    }
    
    /// Call this on app launch to ensure bundled maps are available in Documents/Maps
    func ensureMapsDirectory() {
        let fileManager = FileManager.default
        if !hasCopiedBundledMaps {
            if let bundleMapsURL = Bundle.main.url(forResource: "Maps", withExtension: nil) {
                do {
                    if fileManager.fileExists(atPath: mapsDirectory.path) {
                        try fileManager.removeItem(at: mapsDirectory)
                    }
                    try fileManager.copyItem(at: bundleMapsURL, to: mapsDirectory)
                    hasCopiedBundledMaps = true
                } catch {
                    print("Failed to copy bundled Maps: \(error)")
                }
            } else {
                print("Maps directory not found in bundle.")
            }
        }
    }
    
    /// Helper to get a file URL for a map asset (SVG or JSON)
    func mapFileURL(department: String, fileName: String) -> URL? {
        let dir = mapsDirectory.appendingPathComponent(selectedDepartment)
        let fileURL = dir.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    func getAllAvailableMapNames() -> [String] {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: mapsDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            let directories = contents.filter { url in
                var isDir: ObjCBool = false
                return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
            }
            return directories.map { $0.lastPathComponent }
        } catch {
            print("Failed reading the directory: \(error)")
            return []
        }
    }
    
    func getAvailableDepartments() -> [(internalName: String, displayName: LocalizedText)] {
        return loadedMapDescriptions.map { (key, mapDescription) in
            (internalName: mapDescription.internalName, displayName: mapDescription.title)
        }
    }

    func preloadAllDepartments() async {
        var departments = ["spbu-mm"]
        departments += getAllAvailableMapNames() // we assert that if the folder is present - loading was successfull
        for dep in departments where loadedMapDescriptions[dep] == nil {
            do {
                let mapDescription = try await mapDataService.loadMapData(for: dep)
                loadedMapDescriptions[dep] = mapDescription
            } catch {
                print("Failed to load map for \(dep): \(error)")
            }
        }
    }

    // In loadCustomMapFromServer, use extractCustomMap and update loadedMapDescriptions
    func loadCustomMapFromServer(mapCode: String) async {
        let directory = URL(string: "http://localhost:8080/maps/" + mapCode)!
        guard let session = sessionStore, let token = session.token else {
            print("No session or token")
            return
        }
        do {
            let remoteService = MapRemoteService(session: session)
            let zipURL = try await remoteService.downloadMap(url: directory)
            if let mapDir = extractCustomMap(zipURL: zipURL) {
                let files = try FileManager.default.contentsOfDirectory(at: mapDir, includingPropertiesForKeys: nil)
                if let jsonFile = files.first(where: { $0.pathExtension.lowercased() == "json" }) {
                    let jsonData = try Data(contentsOf: jsonFile)
                    let mapDesc = try JSONDecoder().decode(MapDescription.self, from: jsonData)
                    Task { @MainActor in
                        self.loadedMapDescriptions[mapDesc.internalName] = mapDesc
                        self.selectedDepartment = mapDesc.internalName
                    }
                    let svgs = files.filter { $0.pathExtension.lowercased() == "svg" }
                    print("SVG files:", svgs.map { $0.lastPathComponent })
                } else {
                    print("❌ JSON file not found in extracted map directory")
                }
            }
        } catch {
            print("Error while loading map:", error)
        }
    }

    func setSessionStore(_ session: SessionStore) {
        sessionStore = session
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
        mapFileURL(department: selectedDepartment, fileName: "floor\(selectedFloor).svg")
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

    // When extracting a custom map, always extract to Documents/Maps/<mapCode>/
    func extractCustomMap(zipURL: URL) -> URL? {
        let fileManager = FileManager.default
        let tmpDestinationURL = mapsDirectory.appendingPathComponent("tmp")
        do {
            if fileManager.fileExists(atPath: tmpDestinationURL.path) {
                try fileManager.removeItem(at: tmpDestinationURL)
            }
            try fileManager.createDirectory(at: tmpDestinationURL, withIntermediateDirectories: true)
            try fileManager.unzipItem(at: zipURL, to: tmpDestinationURL)
            try fileManager.removeItem(at: zipURL)

            let fileManager = FileManager.default
            let tmpDestinationURL = mapsDirectory.appendingPathComponent("tmp")

            do {
                let contents = try fileManager.contentsOfDirectory(
                    at: tmpDestinationURL,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                )

                if let jsonFile = contents.first(where: { $0.pathExtension.lowercased() == "json" }) {
                    let mapInternalName = jsonFile.deletingPathExtension().lastPathComponent

                    print("Found JSON file:", jsonFile.lastPathComponent)
                    print("Internal name:", mapInternalName)

                    let mapDirectoryURL = mapsDirectory.appendingPathComponent(mapInternalName)
                    
                    if fileManager.fileExists(atPath: mapDirectoryURL.path) {
                        try fileManager.removeItem(at: mapDirectoryURL)
                    }
                    print(mapDirectoryURL, tmpDestinationURL)

                    try fileManager.moveItem(at: tmpDestinationURL, to: mapDirectoryURL)
                    
                    return mapDirectoryURL
                } else {
                    print("❌ No JSON file found in tmp directory")
                }
            } catch {
                print("Error reading tmp directory:", error)
            }

        } catch {
            print("Failed to unzip custom map: \(error)")
            return nil
        }
        return nil
    }
}
