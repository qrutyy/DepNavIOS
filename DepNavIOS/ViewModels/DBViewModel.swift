//
//  DBViewModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 04.07.2025.
//

import Foundation

@MainActor // ИЗМЕНЕНИЕ: Помечаем класс как работающий в главном потоке.
           // Это гарантирует, что все @Published свойства обновляются безопасно.
class DatabaseViewModel: ObservableObject {
    @Published var historyItems: [HistoryModel] = []
    @Published var DBHandlerItems: [DBHandlerModel] = [] // Предполагаем, что это тоже нужно будет переделать по аналогии
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // ИЗМЕНЕНИЕ: Зависимость от "контракта" (протокола), а не от конкретной реализации.
    private let databaseService: DatabaseServiceProtocol

    // ИЗМЕНЕНИЕ: Внедрение зависимости через конструктор.
    // Позволяет подменять реальный сервис на фальшивый в тестах.
    init(databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.databaseService = databaseService
        // Загружаем данные при инициализации.
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
            // Обновления @Published свойств теперь автоматически происходят в главном потоке
            // благодаря @MainActor на классе.
            self.historyItems = items.sorted(by: { $0.id > $1.id }) // Сразу сортируем для UI
            self.isLoading = false
        }
    }

    func addHistoryItem(_ item: HistoryModel) {
        Task {
            let success = await databaseService.addHistoryItem(item)
            if success {
                // Если добавление успешно, просто вставляем новый элемент в начало массива,
                // вместо того чтобы перезагружать все из БД. Это эффективнее.
                self.historyItems.insert(item, at: 0)
            } else {
                self.errorMessage = "Не удалось добавить элемент истории"
            }
        }
    }
    
    func addHistoryItem(_ item: InternalMarkerModel, department: String) {
        Task {
            let success = await databaseService.addHistoryItem(item.toHistoryModel(currentDepartment: department))
            if success {
                // Если добавление успешно, просто вставляем новый элемент в начало массива,
                // вместо того чтобы перезагружать все из БД. Это эффективнее.
                self.historyItems.insert(item.toHistoryModel(currentDepartment: department), at: 0)
            } else {
                self.errorMessage = "Не удалось добавить элемент истории"
            }
        }
    }

    func updateHistoryItem(_ item: HistoryModel) {
        Task {
            let success = await databaseService.updateHistoryItem(item)
            if success, let index = historyItems.firstIndex(where: { $0.id == item.id }) {
                // Обновляем элемент прямо в массиве.
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
                // Удаляем элемент из массива.
                self.historyItems.removeAll { $0.id == id }
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

    // MARK: - Common Methods

    func loadData() {
        // Запускаем асинхронные задачи
        Task {
            loadHistoryItems()
            // loadDBHandlerItems() // По аналогии нужно будет реализовать
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
