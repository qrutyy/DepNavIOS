//
//  FloorSelectionView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 05.07.2025.
//

import SwiftUI

struct FloorSelectionView: View {
    @Binding var selectedFloor: Int
    let onFloorChange: (Int) -> Void
    let availableFloors: [Int]

    var body: some View {
        if !availableFloors.isEmpty {
            VStack(spacing: 12) {
                ForEach(availableFloors, id: \.self) { floor in
                    Button(action: {
                        onFloorChange(floor)
                    }) {
                        Text(String(floor))
                            .fontWeight(.medium)
                            .frame(width: 44, height: 44)
                            .background(selectedFloor == floor ? Color.blue : Color.clear)
                            .foregroundColor(selectedFloor == floor ? .white : .primary)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(6)
            .background(.thinMaterial)
            .cornerRadius(16)
            .shadow(radius: 3)
            .padding(.top, 50)
            .padding(.trailing, 16)
        } else {
            Text("No floors available")
        }
    }
}

//
// #Preview {
//    FloorSelectionView(selectedFloor: 1, onFloorChange: {floor in print("Selected floor: \(floor)")}, availableFloors: [1, 2, 3, 4])
// }
