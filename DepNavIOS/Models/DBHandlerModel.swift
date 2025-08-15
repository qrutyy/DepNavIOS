//
//  DBHandlerModel.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 04.07.2025.
//

class DepartmentMapModel: Codable {}

// should be created only once.
class DBHandlerModel: Codable {
    var id: Int = 1
    var name: String = "dbHandlerModel"
    var result: String = ""
    var availableDepartments: [String]?
    var historyLength: Int = 0
    var historyList: [MapObjectModel]?
    var favoritesLength: Int = 0
    var favoritesList: [MapObjectModel]?

    init() {}

    init(id: Int, name: String?, result: String, availableDepartments: [String]?, historyLength: Int?, historyList: [MapObjectModel]? = nil, favoritesLength: Int?, favoriteList: [MapObjectModel]? = nil) {
        self.id = id
        self.name = name ?? "dbHandlerModel"
        self.result = result
        self.availableDepartments = availableDepartments
        self.historyLength = historyLength ?? 0
        self.historyList = historyList
        self.favoritesLength = favoritesLength ?? 0
        favoritesList = favoriteList
    }
}
