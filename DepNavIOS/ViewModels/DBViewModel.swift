//
//  DBViewModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 04.07.2025.
//

import Foundation

class DatabaseViewModel: ObservableObject {
    @Published var historyItems: [HistoryModel] = []
    @Published var DBHandlerItems: [DBHandlerModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var historyLength: Int?

    private let databaseManager = DatabaseManager.shared

    init() {
        loadData()
    }

    // MARK: - History Methods

    func loadHistoryItems() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let items = self.databaseManager.getAllHistory()
            DispatchQueue.main.async {
                self.historyItems = items
                self.isLoading = false
            }
        }
    }

    func addHistoryItem(_ item: HistoryModel) {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let success = self.databaseManager.insertHistory(item)
            DispatchQueue.main.async {
                if success {
                    self.loadHistoryItems()
                    self.historyLength = self.historyItems.count
                } else {
                    self.errorMessage = "Не удалось добавить элемент истории"
                    self.isLoading = false
                }
            }
        }
    }

    func updateHistoryItem(_ item: HistoryModel) {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let success = self.databaseManager.updateHistory(item)
            DispatchQueue.main.async {
                if success {
                    self.loadHistoryItems()
                } else {
                    self.errorMessage = "Не удалось обновить элемент истории"
                    self.isLoading = false
                }
            }
        }
    }

    func deleteHistoryItem(id: Int) {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let success = self.databaseManager.deleteHistory(id: id)
            DispatchQueue.main.async {
                if success {
                    self.loadHistoryItems()
                } else {
                    self.errorMessage = "Не удалось удалить элемент истории"
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - DBHandler Methods

    func loadDBHandlerItems() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let items = self.databaseManager.getAllDBHandlers()
            DispatchQueue.main.async {
                self.DBHandlerItems = items
                self.isLoading = false
            }
        }
    }

    func addDBHandlerItem(_ item: DBHandlerModel) {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let success = self.databaseManager.insertDBHandler(item)
            DispatchQueue.main.async {
                if success {
                    self.loadDBHandlerItems()
                } else {
                    self.errorMessage = "Не удалось добавить элемент DBHandler"
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Common Methods

    func loadData() {
        loadHistoryItems()
        loadDBHandlerItems()
    }

    func clearError() {
        errorMessage = nil
    }
}
