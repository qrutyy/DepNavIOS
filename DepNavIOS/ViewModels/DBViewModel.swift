//
//  DBViewModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 04.07.2025.
//

import Foundation

// This VM stores the local cache of the DB, to provide easier and faster access to the data. (FavoriteItems + HistoryItems)
// The actual DB data handling occures by calling the DatabaseService.

@MainActor
// It guarantees that all the @Published properties are updating safely.
class DatabaseViewModel: ObservableObject {
    @Published var historyItems: [MapObjectModel] = []
    @Published var favoriteItems: [MapObjectModel] = []
    @Published var DBHandlerItems: [DBHandlerModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let databaseService: DatabaseServiceProtocol

    init(databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.databaseService = databaseService
        loadData()
    }

    var historyLength: Int {
        historyItems.count
    }

    // MARK: - History Methods

    func loadHistoryItems() {
        isLoading = true
        errorMessage = nil
        Task {
            let items = await databaseService.getHistoryItems()
            // @Published properties updates are happening in the main thread, bc of the @MainActor
            self.historyItems = items.sorted(by: { $0.id > $1.id }) // Sort for the UI
            self.isLoading = false
        }
    }

    func loadFavoriteItems() {
        isLoading = true
        errorMessage = nil
        Task {
            let items = await databaseService.getFavoriteItems()
            // @Published properties updates are happening in the main thread, bc of the @MainActor
            self.favoriteItems = items.sorted(by: { $0.id > $1.id }) // Sort for the UI
            self.isLoading = false
        }
    }

    func addHistoryItem(_ item: MapObjectModel) {
        Task {
            let success = await databaseService.addHistoryItem(item)
            if success {
                self.historyItems.insert(item, at: 0)
            } else {
                self.errorMessage = "Не удалось добавить элемент истории"
            }
        }
    }

    func addHistoryItem(_ item: InternalMarkerModel, department: String) {
        Task {
            let success = await databaseService.addHistoryItem(item.toMapObjectModel(currentDepartment: department))
            if success {
                let localHistoryItem = item.toMapObjectModel(currentDepartment: department)
                localHistoryItem.id = Int.random(in: 1 ... 1_000_000)
                self.historyItems.insert(localHistoryItem, at: 0)
            } else {
                self.errorMessage = "Не удалось добавить элемент истории"
            }
        }
    }

    func addFavoritesItem(_ item: InternalMarkerModel, department: String) {
        Task {
            let success = await databaseService.addFavoriteItem(item.toMapObjectModel(currentDepartment: department))
            if success {
                self.favoriteItems.insert(item.toMapObjectModel(currentDepartment: department), at: 0)
            } else {
                self.errorMessage = "Не удалось добавить элемент истории"
            }
        }
    }

    func updateHistoryItem(_ item: MapObjectModel) {
        Task {
            let success = await databaseService.updateHistoryItem(item)
            if success, let index = historyItems.firstIndex(where: { $0.id == item.id }) {
                self.historyItems[index] = item
            } else {
                self.errorMessage = "Не удалось обновить элемент истории"
            }
        }
    }

    func deleteHistoryItem(id: Int) {
        Task {
            let success = await databaseService.deleteHistoryItem(id: id)
            if success {
                self.historyItems.removeAll { $0.id == id }
            } else {
                self.errorMessage = "Не удалось удалить элемент истории"
            }
        }
    }

    func deleteFavoriteItem(id: Int) {
        Task {
            let success = await databaseService.deleteFavoriteItem(id: id)
            if success {
                self.favoriteItems.removeAll { $0.id == id }
            } else {
                self.errorMessage = "Не удалось удалить элемент истории"
            }
        }
    }

    func clearAllHistory() {
        Task {
            let success = await databaseService.clearHistory()
            if success {
                self.historyItems.removeAll()
            } else {
                self.errorMessage = "Не удалось очистить историю"
            }
        }
    }

    func clearAllFavorites() {
        Task {
            let success = await databaseService.clearFavorites()
            if success {
                self.favoriteItems.removeAll()
            } else {
                self.errorMessage = "Не удалось очистить историю"
            }
        }
    }

    // MARK: - Common Methods

    func loadData() {
        Task {
            loadHistoryItems()
            loadFavoriteItems()
        }
    }

    func clearError() {
        errorMessage = nil
    }

    func checkTablesExist() async -> Bool {
        let result = await databaseService.checkTablesExist()
        return result
    }
}
