//
//  InternalMarkerModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 06.07.2025.
//

import SwiftUI

struct InternalMarkerModel: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String?
    let location: String?
    let floor: Int
    let coordinate: CGPoint
    let type: MarkerType
    let marker: Marker
    let department: String
}

extension InternalMarkerModel {
    func toMapObjectModel(currentDepartment _: String) -> MapObjectModel {
        MapObjectModel(
            id: nil,
            floor: floor,
            department: department,
            objectTitle: title,
            objectDescription: description,
            objectTypeName: type.displayName,
            objectLocation: location
        )
    }
}
