//
//  MapObjectViewModel.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 20.07.2025.
//

import Foundation

func getFormattedTitle(objectTitle: String?, objectTypeName: String?) -> String {
    let type = objectTypeName ?? ""
    let title = objectTitle ?? ""
    return "\(type) \(title)".trimmingCharacters(in: .whitespaces)
}

func getMapObjectIconByType(objectTypeName: String?) -> String {
    switch objectTypeName {
    case "Entrance": "door.french.open"
    case "Room": "door.left.hand.open"
    case "Stairs up": "arrow.up.square"
    case "Stairs down": "arrow.down.square"
    case "Stairs both": "arrow.up.arrow.down.square"
    case "Elevator": "arrow.up.and.down.square"
    case "WC man", "WC woman", "WC": "toilet"
    default: "mappin.circle"
    }
}
