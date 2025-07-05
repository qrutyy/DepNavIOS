//
//  DatabaseService.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import Foundation

protocol DatabaseServiceProtocol {
    func addHistoryItem(_ item: HistoryModel) async
    func getHistoryItems() async -> [HistoryModel]
    func updateHistoryItem(_ item: HistoryModel) async
    func deleteHistoryItem(id: Int) async
    func clearHistory() async
}

class DatabaseService: DatabaseServiceProtocol {
    private let databaseManager = DatabaseManager.shared

    func addHistoryItem(_ item: HistoryModel) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                let success = self.databaseManager.insertHistory(item)
                DispatchQueue.main.async {
                    continuation.resume()
                }
            }
        }
    }

    func getHistoryItems() async -> [HistoryModel] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                let items = self.databaseManager.getAllHistory()
                DispatchQueue.main.async {
                    continuation.resume(returning: items)
                }
            }
        }
    }

    func updateHistoryItem(_ item: HistoryModel) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                let success = self.databaseManager.updateHistory(item)
                DispatchQueue.main.async {
                    continuation.resume()
                }
            }
        }
    }

    func deleteHistoryItem(id: Int) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                let success = self.databaseManager.deleteHistory(id: id)
                DispatchQueue.main.async {
                    continuation.resume()
                }
            }
        }
    }

    func clearHistory() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                // Implementation for clearing all history
                DispatchQueue.main.async {
                    continuation.resume()
                }
            }
        }
    }
}
