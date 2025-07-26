//
//  MapJSONModel.swift
//  DepNavIOS
//
//  Created based on the JSON schema
//

import CoreGraphics // For CGPoint
import Foundation

// MARK: - Main structure describing the entire map file

struct MapDescription: Codable {
    let id: Int
    let internalName: String
    let title: LocalizedText
    let floorWidth: Int
    let floorHeight: Int
    let floors: [Floor]
}

// MARK: - Structures for nested objects

// Describes localized text (e.g., for the map's title)
struct LocalizedText: Codable {
    let ru: String
    let en: String
}

// Describes a single floor and its markers
struct Floor: Codable {
    let floor: Int
    let markers: [Marker]
}

// Describes a single marker (point of interest)
// This structure replaces your MarkerModel for parsing
struct Marker: Codable, Identifiable, Hashable {
    // To conform to Identifiable, you can use a combination of fields,
    // especially if the JSON does not provide a unique id.
    var id: String { "\(type.rawValue)-\(x)-\(y)" }

    let type: MarkerType
    let x: Int
    let y: Int
    let ru: MarkerDetails
    let en: MarkerDetails

    // A convenient computed property to get the coordinates
    var coordinate: CGPoint {
        CGPoint(x: x, y: y)
    }
}

// Describes the marker details (title, description) for a single language
struct MarkerDetails: Codable, Hashable {
    let title: String?
    let location: String?
    let description: String?
}

// MARK: - Enum for the marker type

// This enum must exactly match the values in the JSON schema

enum MarkerType: String, Codable, CaseIterable, Hashable {
    case ENTRANCE = "Entrance"
    case ROOM = "Room"
    case STAIRS_UP = "Stairs up" // added for compatability with @TimPushkin JSON's
    case STAIRS_DOWN = "Stairs down" // added for compatability with @TimPushkin JSON's
    case STAIRS_BOTH = "Stairs both"
    case ELEVATOR = "Elevator"
    case WC_MAN = "WC man"
    case WC_WOMAN = "WC woman"
    case WC
    case OTHER = "Other"

    // If you need more user-friendly names for the UI,
    // you can add a computed property:
    var displayName: String {
        switch self {
        case .ENTRANCE: "Entrance"
        case .ROOM: "Room"
        case .STAIRS_UP: "Stairs Up"
        case .STAIRS_DOWN: "Stairs Down"
        // ... and so on for all cases
        default: "Object"
        }
    }
}
