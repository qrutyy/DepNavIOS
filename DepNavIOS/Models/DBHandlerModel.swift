//
//  DBHandlerModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 04.07.2025.
//

class DepartmentMapModel: Codable {}

class HistoryModel: Codable {
    var id: Int = 1
    var department: String = ""
    var floor: Int = -99
    var objectTitle: String = ""
    var objectDescription: String = ""
    var objectTypeName: String = ""

    init() {}

    init(id: Int, floor: Int?, department: String? = nil, objectTitle: String?, objectDescription: String?, objectTypeName: String?) {
        self.id = id
        self.department = department ?? ""
        self.floor = floor != nil ? floor! : -99
        self.objectTitle = objectTitle ?? ""
        self.objectDescription = objectDescription ?? "unknown"
        self.objectTypeName = objectTypeName ?? ""
    }
}

// should be created only once.
class DBHandlerModel: Codable {
    var id: Int = 1
    var name: String = "dbHandlerModel"
    var result: String = ""
    var availableDepartments: [String]?
    var historyLength: Int = 0
    var historyList: [HistoryModel]?

    init() {}

    init(id: Int, name: String?, result: String, availableDepartments: [String]?, historyLength: Int?, historyList: [HistoryModel]? = nil) {
        self.id = id
        self.name = name ?? "dbHandlerModel"
        self.result = result
        self.availableDepartments = availableDepartments
        self.historyLength = historyLength ?? 0
        self.historyList = historyList
    }
}
