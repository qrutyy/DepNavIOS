//
//  DBHandlerModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 04.07.2025.
//

class DepartmentMapModel: Codable {}

class HistoryModel: Codable, Identifiable {
    var id: Int = 1
    var department: String = ""
    var floor: Int = -99
    var objectTitle: String = ""
    var objectDescription: String = ""
    var objectTypeName: String = ""

    init() {}

    init(floor: Int?, department: String? = nil, objectTitle: String?, objectDescription: String?, objectTypeName: String?) {
        id = 0
        self.department = department ?? ""
        self.floor = floor != nil ? floor! : -99
        self.objectTitle = objectTitle ?? ""
        self.objectDescription = objectDescription ?? "Not found"
        self.objectTypeName = objectTypeName ?? ""
    }
}

extension HistoryModel {
    func toInternalMarkerModel(mapDescription: MapDescription?) -> InternalMarkerModel? {
        // 1. Убеждаемся, что у нас есть данные карты
        guard let description = mapDescription else {
            print("Conversion failed: mapDescription is nil.")
            return nil
        }

        // 2. Ищем нужный этаж в данных карты.
        // Используем `first(where:)` для безопасного поиска.
        guard let floorData = description.floors.first(where: { $0.floor == self.floor }) else {
            print("Conversion failed: floor \(floor) not found in map data.")
            return nil
        }

        // 3. Ищем на этом этаже маркер с таким же названием.
        guard let originalMarker = floorData.markers.first(where: { marker in
            // Сравниваем названия, учитывая, что в JSON они тоже могут быть опциональными
            (marker.ru.title ?? marker.en.title) == self.objectTitle
        }) else {
            print("Conversion failed: marker with title '\(objectTitle)' not found on floor \(floor).")
            return nil
        }

        // 4. Если все нашлось, создаем и возвращаем полный InternalMarkerModel.
        // ID генерируем заново, чтобы он был стабильным и соответствовал формату.
        let uniqueID = "\(description.internalName)-\(floorData.floor)-\(objectTitle)"

        return InternalMarkerModel(
            id: uniqueID,
            title: objectTitle,
            description: objectDescription,
            floor: floor,
            coordinate: originalMarker.coordinate, // Берем актуальные координаты
            type: originalMarker.type, // Берем актуальный тип
            marker: originalMarker // Сохраняем весь оригинальный объект
        )
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
