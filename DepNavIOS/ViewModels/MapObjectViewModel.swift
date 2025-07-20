//
//  MapObjectUtils.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 20.07.2025.
//

import Foundation

func getFormattedTitle(objectTitle: String?, objectTypeName: String?) -> String {
    let type = objectTypeName ?? ""
    let title = objectTitle ?? ""
    return "\(type) \(title)".trimmingCharacters(in: .whitespaces)
}

func getMapObjectIconByType(objectTypeName: String?) -> String {
    switch objectTypeName {
    case "Entrance": return "door.french.open"
    case "Room": return "door.left.hand.open"
    case "Stairs up": return "arrow.up.square"
    case "Stairs down": return "arrow.down.square"
    case "Stairs both": return "arrow.up.arrow.down.square"
    case "Elevator": return "arrow.up.and.down.square"
    case "WC man", "WC woman", "WC": return "toilet"
    default: return "mappin.circle"
    }
}
