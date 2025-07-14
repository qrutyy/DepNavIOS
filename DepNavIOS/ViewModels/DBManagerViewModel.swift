//
//  DatabaseManager.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 04.07.2025.
//
import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private let dbQueue = DispatchQueue(label: "com.depnavios.database.serialqueue")

    private init() {
        dbQueue.sync {
            self.openDatabase()
            self.createTables()
        }
    }

    deinit {
        dbQueue.sync {
            self.closeDatabase()
        }
    }

    private func openDatabase() {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("AppDatabase.sqlite")

            if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
                print("Successfully opened connection to database.")
            } else {
                print("Unable to open database.")
            }
        } catch {
            print("Could not find database file URL: \(error)")
        }
    }

    private func closeDatabase() {
        if sqlite3_close(db) == SQLITE_OK {
            print("Successfully closed connection to database.")
        } else {
            print("Unable to close database.")
        }
    }
    
    func checkTablesExist() -> Bool {
        let requiredTables: Set<String> = ["History", "Favorites", "DBHandler"]
        var foundTables: Set<String> = []

        let querySQL = "SELECT name FROM sqlite_master WHERE type='table';"
        var statement: OpaquePointer?

        var result = false
        dbQueue.sync {
            if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
                // Loop through all the rows (tables) found
                while sqlite3_step(statement) == SQLITE_ROW {
                    if let tableNameCString = sqlite3_column_text(statement, 0) {
                        let tableName = String(cString: tableNameCString)
                        foundTables.insert(tableName)
                    }
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failed to prepare statement for checking tables: \(errmsg)")
            }
            sqlite3_finalize(statement)

            // A set's isSuperset(of:) checks if it contains all elements from another set.
            // This is a very clean way to verify all required tables were found.
            result = foundTables.isSuperset(of: requiredTables)
        }

        print("All required tables exist: \(result)")
        return result
    }

    private func createTables() {
        createHistoryTable()
        createFavoriteTable()
        createDBHandlerTable()
    }

    private func createDBHandlerTable() {
        let createTableString = """
            CREATE TABLE IF NOT EXISTS DBHandler(
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            Name TEXT,
            Result TEXT,
            AvailableDepartments TEXT,
            HistoryList TEXT);
        """
        if sqlite3_exec(db, createTableString, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error creating DBHandler table: \(errmsg)")
        }
    }

    private func createHistoryTable() {
        let createTableString = """
            CREATE TABLE IF NOT EXISTS History(
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            Department TEXT,
            Floor INT,
            ObjectName TEXT,
            ObjectDescription TEXT,
            ObjectTypeName TEXT);
        """
        if sqlite3_exec(db, createTableString, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error creating History table: \(errmsg)")
        }
    }

    private func createFavoriteTable() {
        let createTableString = """
            CREATE TABLE IF NOT EXISTS Favorites(
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            Department TEXT,
            Floor INT,
            ObjectName TEXT,
            ObjectDescription TEXT,
            ObjectTypeName TEXT);
        """
        if sqlite3_exec(db, createTableString, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error creating History table: \(errmsg)")
        }
    }

    private func bind(text: String?, to statement: OpaquePointer?, at index: Int32) {
        guard let text = text else {
            sqlite3_bind_null(statement, index)
            return
        }
        sqlite3_bind_text(statement, index, (text as NSString).utf8String, -1, nil)
    }

    private func bind(int: Int?, to statement: OpaquePointer?, at index: Int32) {
        guard let int = int else {
            sqlite3_bind_null(statement, index)
            return
        }
        sqlite3_bind_int(statement, index, Int32(int))
    }

    // MARK: - History CRUD Operations

    func insertHistory(_ history: MapObjectModel) -> Bool {
        var success = false
        dbQueue.sync {
            let insertSQL = "INSERT INTO History (Department, Floor, ObjectName, ObjectDescription, ObjectTypeName) VALUES (?, ?, ?, ?, ?);"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
                bind(text: history.department, to: statement, at: 1)
                bind(int: history.floor, to: statement, at: 2)
                bind(text: history.objectTitle, to: statement, at: 3)
                bind(text: history.objectDescription, to: statement, at: 4)
                bind(text: history.objectTypeName, to: statement, at: 5)

                if sqlite3_step(statement) == SQLITE_DONE {
                    success = true
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("Failure inserting history: \(errmsg)")
                }
            }
            sqlite3_finalize(statement)
        }
        return success
    }

    func getAllHistory() -> [MapObjectModel] {
        var histories: [MapObjectModel] = []
        dbQueue.sync {
            let querySQL = "SELECT Id, Department, Floor, ObjectName, ObjectDescription, ObjectTypeName FROM History;"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let department = String(cString: sqlite3_column_text(statement, 1))
                    let floor = Int(sqlite3_column_int(statement, 2))
                    let objectTitle = String(cString: sqlite3_column_text(statement, 3))
                    let objectDescription = String(cString: sqlite3_column_text(statement, 4))
                    let objectTypeName = String(cString: sqlite3_column_text(statement, 5))

                    let history = MapObjectModel(
                        id: id,
                        floor: floor,
                        department: department,
                        objectTitle: objectTitle,
                        objectDescription: objectDescription,
                        objectTypeName: objectTypeName
                    )
                    histories.append(history)
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failure preparing select all history: \(errmsg)")
            }
            sqlite3_finalize(statement)
        }
        return histories
    }

    func updateHistory(_ history: MapObjectModel) -> Bool {
        var success = false
        dbQueue.sync {
            let updateSQL = "UPDATE History SET Department = ?, Floor = ?, ObjectName = ?, ObjectDescription = ?, ObjectTypeName = ? WHERE Id = ?;"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
                bind(text: history.department, to: statement, at: 1)
                bind(int: history.floor, to: statement, at: 2)
                bind(text: history.objectTitle, to: statement, at: 3)
                bind(text: history.objectDescription, to: statement, at: 4)
                bind(text: history.objectTypeName, to: statement, at: 5)
                bind(int: history.id, to: statement, at: 6)

                if sqlite3_step(statement) == SQLITE_DONE { success = true }
            }
            sqlite3_finalize(statement)
        }
        return success
    }

    func deleteHistory(id: Int) -> Bool {
        var success = false
        dbQueue.sync {
            let deleteSQL = "DELETE FROM History WHERE Id = ?;"
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(id))
                if sqlite3_step(statement) == SQLITE_DONE { success = true }
            }
            sqlite3_finalize(statement)
        }
        return success
    }

    func clearAllHistory() -> Bool {
        var success = false
        dbQueue.sync {
            let deleteSQL = "DELETE FROM History;"
            if sqlite3_exec(db, deleteSQL, nil, nil, nil) == SQLITE_OK {
                success = true
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error clearing history table: \(errmsg)")
            }
        }
        return success
    }

    // MARK: - DBHandler CRUD Operations

    // Note: The logic for storing arrays as JSON strings is maintained.

    func insertDBHandler(_ handler: DBHandlerModel) -> Bool {
        var success = false
        dbQueue.sync {
            let insertSQL = "INSERT INTO DBHandler (Name, Result, AvailableDepartments, HistoryList, FavoritesList) VALUES (?, ?, ?, ?, ?);"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
                bind(text: handler.name, to: statement, at: 1)
                bind(text: handler.result, to: statement, at: 2)

                let encoder = JSONEncoder()
                if let departmentsData = try? encoder.encode(handler.availableDepartments),
                   let departmentsJSON = String(data: departmentsData, encoding: .utf8) {
                    bind(text: departmentsJSON, to: statement, at: 3)
                }

                if let historyData = try? encoder.encode(handler.historyList),
                   let historyJSON = String(data: historyData, encoding: .utf8) {
                    bind(text: historyJSON, to: statement, at: 4)
                }

                if let favoritesData = try? encoder.encode(handler.favoritesList),
                   let favoritesJSON = String(data: favoritesData, encoding: .utf8) {
                    bind(text: favoritesJSON, to: statement, at: 4)
                }

                if sqlite3_step(statement) == SQLITE_DONE {
                    success = true
                }
            }
            sqlite3_finalize(statement)
        }
        return success
    }

    func getAllDBHandlers() -> [DBHandlerModel] {
        var handlers: [DBHandlerModel] = []
        dbQueue.sync {
            let querySQL = "SELECT Id, Name, Result, AvailableDepartments, HistoryList, FavoritesList FROM DBHandler;"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let name = String(cString: sqlite3_column_text(statement, 1))
                    let result = String(cString: sqlite3_column_text(statement, 2))

                    let decoder = JSONDecoder()
                    var departments: [String]?
                    if let departmentsText = sqlite3_column_text(statement, 3), let data = String(cString: departmentsText).data(using: .utf8) {
                        departments = try? decoder.decode([String].self, from: data)
                    }

                    var historyList: [MapObjectModel]?
                    if let historyText = sqlite3_column_text(statement, 4), let data = String(cString: historyText).data(using: .utf8) {
                        historyList = try? decoder.decode([MapObjectModel].self, from: data)
                    }

                    var favoritesList: [MapObjectModel]?
                    if let favoritesText = sqlite3_column_text(statement, 4), let data = String(cString: favoritesText).data(using: .utf8) {
                        favoritesList = try? decoder.decode([MapObjectModel].self, from: data)
                    }

                    let handler = DBHandlerModel(
                        id: id,
                        name: name,
                        result: result,
                        availableDepartments: departments,
                        historyLength: historyList?.count, // Deriving length from the list
                        historyList: historyList,
                        favoritesLength: favoritesList?.count, // for faster "get"
                        favoriteList: favoritesList
                    )
                    handlers.append(handler)
                }
            }
            sqlite3_finalize(statement)
        }
        return handlers
    }

    // MARK: Favorites section

    func getFavoritesCount() -> Int {
        var count = 0

        dbQueue.sync {
            let querySQL = "SELECT COUNT(*) FROM Favorites;"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_ROW {
                    count = Int(sqlite3_column_int(statement, 0))
                }
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Ошибка подготовки запроса getFavoritesCount: \(errorMessage)")
            }
            sqlite3_finalize(statement)
        }
        return count
    }

    func insertFavorites(_ history: MapObjectModel) -> Bool {
        if getFavoritesCount() < 4 {
            // i thought that even though another (almost the same) table as History - will be a better way to support favorite item than making another flag
            var success = false
            dbQueue.sync {
                let insertSQL = "INSERT INTO Favorites (Department, Floor, ObjectName, ObjectDescription, ObjectTypeName) VALUES (?, ?, ?, ?, ?);"
                var statement: OpaquePointer?

                if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
                    bind(text: history.department, to: statement, at: 1)
                    bind(int: history.floor, to: statement, at: 2)
                    bind(text: history.objectTitle, to: statement, at: 3)
                    bind(text: history.objectDescription, to: statement, at: 4)
                    bind(text: history.objectTypeName, to: statement, at: 5)

                    if sqlite3_step(statement) == SQLITE_DONE {
                        success = true
                    } else {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("Failure inserting history: \(errmsg)")
                    }
                }
                sqlite3_finalize(statement)
            }
            return success
        } else {
            print("Favorites already exist and is full.")
            return false
        }
    }

    func getAllFavorites() -> [MapObjectModel] {
        var histories: [MapObjectModel] = []
        dbQueue.sync {
            let querySQL = "SELECT Id, Department, Floor, ObjectName, ObjectDescription, ObjectTypeName FROM Favorites ORDER BY Id ASC;"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, querySQL, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let department = String(cString: sqlite3_column_text(statement, 1))
                    let floor = Int(sqlite3_column_int(statement, 2))
                    let objectTitle = String(cString: sqlite3_column_text(statement, 3))
                    let objectDescription = String(cString: sqlite3_column_text(statement, 4))
                    let objectTypeName = String(cString: sqlite3_column_text(statement, 5))

                    let history = MapObjectModel(
                        id: id,
                        floor: floor,
                        department: department,
                        objectTitle: objectTitle,
                        objectDescription: objectDescription,
                        objectTypeName: objectTypeName
                    )
                    histories.append(history)
                }
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Failure preparing select all history: \(errmsg)")
            }
            sqlite3_finalize(statement)
        }
        return histories
    }

    func updateFavorite(_ history: MapObjectModel) -> Bool {
        var success = false
        dbQueue.sync {
            let updateSQL = "UPDATE Favourites SET Department = ?, Floor = ?, ObjectName = ?, ObjectDescription = ?, ObjectTypeName = ? WHERE Id = ?;"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
                bind(text: history.department, to: statement, at: 1)
                bind(int: history.floor, to: statement, at: 2)
                bind(text: history.objectTitle, to: statement, at: 3)
                bind(text: history.objectDescription, to: statement, at: 4)
                bind(text: history.objectTypeName, to: statement, at: 5)
                bind(int: history.id, to: statement, at: 6)

                if sqlite3_step(statement) == SQLITE_DONE { success = true }
            }
            sqlite3_finalize(statement)
        }
        return success
    }

    func deleteFavorite(id: Int) -> Bool {
        var success = false
        dbQueue.sync {
            let deleteSQL = "DELETE FROM Favorites WHERE Id = ?;"
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, Int32(id))
                if sqlite3_step(statement) == SQLITE_DONE { success = true }
            }
            sqlite3_finalize(statement)
        }
        return success
    }

    func clearAllFavorites() -> Bool {
        var success = false
        dbQueue.sync {
            let deleteSQL = "DELETE FROM Favorites;"
            if sqlite3_exec(db, deleteSQL, nil, nil, nil) == SQLITE_OK {
                success = true
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error clearing history table: \(errmsg)")
            }
        }
        return success
    }
}
