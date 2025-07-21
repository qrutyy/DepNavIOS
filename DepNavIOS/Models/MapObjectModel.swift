//
//  MapObjectModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 19.07.2025.
//

import Foundation

class MapObjectModel: Codable, Identifiable {
    var id: Int = 1
    var department: String = ""
    var floor: Int = -99
    var objectTitle: String = ""
    var objectDescription: String = ""
    var objectTypeName: String = ""
    var objectLocation: String = ""

    init() {}

    init(id: Int?, floor: Int?, department: String? = nil, objectTitle: String?, objectDescription: String?, objectTypeName: String?, objectLocation: String?) {
        if id != nil {
            self.id = id!
        }
        self.department = department ?? ""
        self.floor = floor != nil ? floor! : -99
        self.objectTitle = objectTitle ?? ""
        self.objectDescription = objectDescription ?? ""
        self.objectTypeName = objectTypeName ?? ""
        self.objectLocation = objectLocation ?? ""
    }
}

extension MapObjectModel {
    func toInternalMarkerModel(mapDescription: MapDescription?) -> InternalMarkerModel? {
        guard let description = mapDescription else {
            print("Conversion failed: mapDescription is nil.")
            return nil
        }

        guard let floorData = description.floors.first(where: { $0.floor == self.floor }) else {
            print("Conversion failed: floor \(floor) not found in map data.")
            return nil
        }

        guard let originalMarker = floorData.markers.first(where: { marker in
            (marker.ru.title ?? marker.en.title) == self.objectTitle
        }) else {
            print("Conversion failed: marker with title '\(objectTitle)' not found on floor \(floor).")
            return nil
        }

        let uniqueID = "\(description.internalName)-\(floorData.floor)-\(objectTitle)"

        return InternalMarkerModel(
            id: uniqueID,
            title: objectTitle,
            description: objectDescription,
            location: objectLocation,
            floor: floor,
            coordinate: originalMarker.coordinate,
            type: originalMarker.type,
            marker: originalMarker
        )
    }
}

func stringFormatType(_ objType: String) -> String {
    switch objType {
    case "Room":
        return LocalizedString("marker_type_room")
    case "Entrance":
        return LocalizedString("marker_type_entrance")
    case "Stairs up", "Stairs down", "Stairs both":
        return LocalizedString("marker_type_stairs")
    case "Elevator":
        return LocalizedString("marker_type_elevator")
    case "WC", "WC man", "WC woman":
        return LocalizedString("marker_type_wc")
    default:
        return LocalizedString("marker_type_unknown")
    }
}
