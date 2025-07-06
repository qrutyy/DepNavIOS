//
//  MapViewModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

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
    
    // ИЗМЕНЕНИЕ: Добавляем ViewModel для базы данных как наблюдаемый объект.
    // Теперь MapViewModel управляет логикой БД.
    @Published var dbViewModel = DatabaseViewModel()
    
    // ИЗМЕНЕНИЕ: Добавляем массив для хранения результатов поиска.
    @Published var searchResults: [InternalMarkerModel] = []


    // MARK: - Services and Dependencies
    private let mapDataService: MapDataService
    
    private var loadedMapDescriptions: [String: MapDescription] = [:]

    init(mapDataService: MapDataService = MapDataService()) {
        self.mapDataService = mapDataService
    }

    // MARK: - Map Management
    func loadMapData() async {
        // ИЗМЕНЕНИЕ: Сначала проверяем, есть ли данные в нашем кэше.
        if loadedMapDescriptions[selectedDepartment] != nil {
            print("Map for \(selectedDepartment) already loaded.")
            return // Данные уже есть, ничего не делаем.
        }
        
        isLoading = true
        errorMessage = nil // Сбрасываем старую ошибку
        
        do {
            // ИЗМЕНЕНИЕ: Получаем данные от сервиса и сохраняем в кэш.
            let mapDescription = try await mapDataService.loadMapData(for: selectedDepartment)
            loadedMapDescriptions[selectedDepartment] = mapDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        // ИЗМЕНЕНИЕ: isLoading = false теперь всегда вызывается после завершения операции.
        isLoading = false
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
    
    /// Выполняет поиск маркеров по всем этажам на основе `searchQuery`.
    func searchMarkers() async {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        
        // Включаем индикатор загрузки для поиска
        isLoading = true
        
        // Получаем все маркеры для текущего департамента
        let allMarkers = getAllMarkersForCurrentDepartment()
        
        let query = searchQuery.lowercased()
        
        let filteredMarkers = allMarkers.filter { markerData in
            // Проверяем совпадение в названии, описании или типе
            let titleMatch = (markerData.marker.ru.title?.lowercased().hasPrefix(query) ?? false) ||
            (markerData.marker.en.title?.lowercased().hasPrefix(query) ?? false)
            let typeMatch = markerData.marker.type.displayName.lowercased().hasPrefix(query)
            let descriptionMatch = (markerData.marker.ru.description?.lowercased().hasPrefix(query) ?? false) ||
            (markerData.marker.en.description?.lowercased().hasPrefix(query) ?? false)
            
            return titleMatch || typeMatch || descriptionMatch
        }
        
        // Преобразуем найденные маркеры в нашу модель `InternalMarkerModel`
        self.searchResults = filteredMarkers.map { markerData in
            InternalMarkerModel(
                id: markerData.id,
                title: markerData.marker.ru.title ?? markerData.marker.en.title ?? "Без названия",
                description: markerData.marker.ru.description ?? markerData.marker.en.description,
                floor: markerData.floor,
                coordinate: markerData.marker.coordinate,
                type: markerData.marker.type,
                marker: markerData.marker
            )
        }
        print(searchResults.count)
        isLoading = false
        if (searchResults.count == 1) {
            dbViewModel.addHistoryItem(searchResults[0], department: selectedDepartment)
        } else {
            /// Adding the query item in case we didn't found any matching objects.
            let newHistoryItem = HistoryModel(
                id: (dbViewModel.historyLength) + 1,
                floor: nil,
                department: selectedDepartment,
                objectTitle: searchQuery,
                objectDescription: nil,
                objectTypeName: nil
            )
            dbViewModel.addHistoryItem(newHistoryItem)
        }
    }
    
    /// Вызывается при выборе маркера из списка результатов поиска.
    func selectMarker(_ marker: InternalMarkerModel) {
        // Устанавливаем этаж и координаты для отображения на карте
        self.selectedFloor = marker.floor
        self.markerCoordinate = marker.coordinate
        
        // Очищаем поисковый запрос, чтобы скрыть результаты и показать карту
        self.searchQuery = ""
        self.searchResults = []
        
        // Создаем и добавляем элемент в историю через dbViewModel
        let newHistoryItem = HistoryModel(
            // ИЗМЕНЕНИЕ: Используем `dbViewModel.historyLength + 1` для уникального ID
            id: (dbViewModel.historyLength) + 1,
            floor: marker.floor,
            department: selectedDepartment,
            objectTitle: marker.title,
            objectDescription: marker.description,
            objectTypeName: marker.type.displayName
        )
        dbViewModel.addHistoryItem(newHistoryItem)
    }
    
    /// Вызывается при выборе элемента из списка недавних поисков.
    func selectHistoryItem(_ item: HistoryModel) {
        // Устанавливаем поисковый запрос, чтобы пользователь видел, что он выбрал
        self.searchQuery = item.objectTitle
        
        // Запускаем поиск по этому запросу
        Task {
            await searchMarkers()
            // Если найден ровно один результат, сразу выбираем его
            if let firstResult = searchResults.first, searchResults.count == 1 {
                selectMarker(firstResult)
            }
            // Если результатов несколько, они останутся на экране для выбора пользователем
        }
    }
    
    var availableFloors: [Int] {
        guard let description = currentMapDescription else {
            return []
        }

        return description.floors.map { $0.floor }.sorted()
    }
    
    var currentMapDescription: MapDescription? {
            loadedMapDescriptions[selectedDepartment]
        }
    
    func clearMarker() {
        markerCoordinate = nil
        searchQuery = ""
        searchResults = []
    }
    
    private func getAllMarkersForCurrentDepartment() -> [InternalMarkerModel] {
            guard let mapDescription = currentMapDescription else { return [] }
            return mapDescription.floors.flatMap { floorData in
                floorData.markers.map { marker in
                    InternalMarkerModel(id: marker.id, title: marker.ru.title ?? "", description: marker.ru.description, floor: floorData.floor, coordinate: marker.coordinate, type: marker.type, marker: marker )
                }
            }
        }
}

