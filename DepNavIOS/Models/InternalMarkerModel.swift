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
    let floor: Int
    let coordinate: CGPoint
    let type: MarkerType
    let marker: Marker
}

extension InternalMarkerModel {
    func toMapObjectModel(currentDepartment: String) -> MapObjectModel {
        return MapObjectModel(
            id: nil,
            floor: floor,
            department: currentDepartment,
            objectTitle: title,
            objectDescription: description,
            objectTypeName: type.displayName
        )
    }
}
