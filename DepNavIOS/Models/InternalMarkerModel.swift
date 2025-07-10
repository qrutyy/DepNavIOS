//
//  InternalMarkerModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 06.07.2025.
//

import SwiftUI

// ИЗМЕНЕНИЕ: Модель для найденного маркера, которая содержит всю необходимую информацию для отображения и навигации.
// Она Identifiable, что идеально подходит для SwiftUI.
struct InternalMarkerModel: Identifiable, Equatable {
    let id: String // Уникальный идентификатор, например "floor2-room101"
    let title: String
    let description: String?
    let floor: Int
    let coordinate: CGPoint
    let type: MarkerType
    let marker: Marker
}

extension InternalMarkerModel {
    func toHistoryModel(currentDepartment: String) -> HistoryModel {
        return HistoryModel(
            floor: floor,
            department: currentDepartment,
            objectTitle: title,
            objectDescription: description,
            objectTypeName: type.displayName
        )
    }
}
