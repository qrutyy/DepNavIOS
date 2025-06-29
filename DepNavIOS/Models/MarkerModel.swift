//
//  MarkerModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 29.06.2025.
//

import Foundation

// struct and enum are Decodable, bc JSON parser can't handle non-decodable.
// CaseIterable is Enabled, so the iteration can be performed.
enum MarkerType: String, CaseIterable, Decodable {
    case room = "Room"
    case staircase = "Staircase"
    case bathroom = "Bathroom"
    case entrance = "Entrance"
    case canteen = "Canteen"
    case custom = "Custom"
}

struct MarkerModel: Decodable {
    let id: String // ftm - is the data. mb it will be good to add an independent id
    let x: CGFloat
    let y: CGFloat
    let floor: Int8
    let type: MarkerType
    // let data: String? // would be parsed and presented in different ways, depending on the type

    var coordinate: CGPoint {
        CGPoint(x: x, y: y)
    }
}
