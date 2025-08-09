//
//  DatabaseService.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//
import Foundation

protocol DatabaseServiceProtocol {
    func addHistoryItem(_ item: MapObjectModel) async -> Bool
    func getHistoryItems() async -> [MapObjectModel]
    func updateHistoryItem(_ item: MapObjectModel) async -> Bool
    func deleteHistoryItem(id: Int) async -> Bool
    func clearHistory() async -> Bool

    func addFavoriteItem(_ item: MapObjectModel) async -> Bool
    func getFavoriteItems() async -> [MapObjectModel]
    func updateFavoriteItem(_ item: MapObjectModel) async -> Bool
    func deleteFavoriteItem(id: Int) async -> Bool
    func clearFavorites() async -> Bool
    func checkTablesExist() async -> Bool
}

class DatabaseService: DatabaseServiceProtocol {
    private let databaseManager = DatabaseManager.shared

    // This helper function performs any manager synchronous work
    // in a separate background stream, without blocking the UI, and returns the result.
    private func perform<T>(work: @escaping @Sendable () async -> T) async -> T {
        await Task.detached(priority: .background) {
            await work()
        }.value
    }

    func addHistoryItem(_ item: MapObjectModel) async -> Bool {
        await perform {
            await self.databaseManager.insertHistory(item)
        }
    }

    func getHistoryItems() async -> [MapObjectModel] {
        await perform {
            await self.databaseManager.getAllHistory()
        }
    }

    func updateHistoryItem(_ item: MapObjectModel) async -> Bool {
        await perform {
            await self.databaseManager.updateHistory(item)
        }
    }

    func deleteHistoryItem(id: Int) async -> Bool {
        await perform {
            await self.databaseManager.deleteHistory(id: id)
        }
    }

    func clearHistory() async -> Bool {
        await perform {
            await self.databaseManager.clearAllHistory()
        }
    }

    func addFavoriteItem(_ item: MapObjectModel) async -> Bool {
        await perform {
            await self.databaseManager.insertFavorites(item)
        }
    }

    func getFavoriteItems() async -> [MapObjectModel] {
        await perform {
            await self.databaseManager.getAllFavorites()
        }
    }

    func updateFavoriteItem(_ item: MapObjectModel) async -> Bool {
        await perform {
            await self.databaseManager.updateFavorite(item)
        }
    }

    func deleteFavoriteItem(id: Int) async -> Bool {
        await perform {
            await self.databaseManager.deleteFavorite(id: id)
        }
    }

    func clearFavorites() async -> Bool {
        await perform {
            await self.databaseManager.clearAllFavorites()
        }
    }

    func checkTablesExist() async -> Bool {
        await perform {
            await self.databaseManager.checkTablesExist()
        }
    }
}
