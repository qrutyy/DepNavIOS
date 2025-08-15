//
//  MapControlModel.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 17.07.2025.
//

import SwiftUI

class MapControlModel: ObservableObject {
    @Published var isCentered: Bool = false
    @Published var isZoomedOut: Bool = false
}
