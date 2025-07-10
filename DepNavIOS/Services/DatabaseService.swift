//
//  DatabaseService.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import Foundation

protocol DatabaseServiceProtocol {
    func addHistoryItem(_ item: HistoryModel) async -> Bool
    func getHistoryItems() async -> [HistoryModel]
    func updateHistoryItem(_ item: HistoryModel) async -> Bool
    func deleteHistoryItem(id: Int) async -> Bool
    func clearHistory() async -> Bool
}

class DatabaseService: DatabaseServiceProtocol {
    private let databaseManager = DatabaseManager.shared

    // This helper function performs any manager synchronous work
    // in a separate background stream, without blocking the UI, and returns the result.
    private func perform<T>(work: @escaping @Sendable () -> T) async -> T {
        await Task.detached(priority: .background) {
            work()
        }.value
    }

    func addHistoryItem(_ item: HistoryModel) async -> Bool {
        await perform {
            self.databaseManager.insertHistory(item)
        }
    }

    func getHistoryItems() async -> [HistoryModel] {
        await perform {
            self.databaseManager.getAllHistory()
        }
    }

    func updateHistoryItem(_ item: HistoryModel) async -> Bool {
        await perform {
            self.databaseManager.updateHistory(item)
        }
    }

    func deleteHistoryItem(id: Int) async -> Bool {
        await perform {
            self.databaseManager.deleteHistory(id: id)
        }
    }

    func clearHistory() async -> Bool {
        await perform {
            self.databaseManager.clearAllHistory()
        }
    }
}
