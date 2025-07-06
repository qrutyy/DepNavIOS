//
//  DatabaseService.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//
import Foundation

// "Контракт", который описывает, что должен уметь делать наш сервис баз данных.
protocol DatabaseServiceProtocol {
    func addHistoryItem(_ item: HistoryModel) async -> Bool
    func getHistoryItems() async -> [HistoryModel]
    func updateHistoryItem(_ item: HistoryModel) async -> Bool
    func deleteHistoryItem(id: Int) async -> Bool
    func clearHistory() async -> Bool
}

// ИЗМЕНЕНИЕ: Полностью переписанная реализация для чистоты и ясности.
// Это "прораб", который нанимает "сантехника" (DatabaseManager).
class DatabaseService: DatabaseServiceProtocol {
    private let databaseManager = DatabaseManager.shared

    // Эта функция-помощник выполняет любую синхронную работу менеджера
    // в отдельном фоновом потоке, не блокируя UI, и возвращает результат.
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
