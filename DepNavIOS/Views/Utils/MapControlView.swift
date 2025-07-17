//
//  MapControlView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 17.07.2025.
//

import SwiftUI

struct MapControlView: View {
    @Binding var isCentered: Bool
    @Binding var isZoomedOut: Bool

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action:
                    { isZoomedOut = true }
                ) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.secondary) // .secondary - хороший адаптивный серый
                }
                .frame(width: 50, height: 50)
                .background(Color(.systemGray6)) // .systemGray6 - еще один хороший вариант для фона
                .clipShape(Rectangle())
                .cornerRadius(16)
                .shadow(radius: 2)
            }

            Spacer().frame(height: 10)

            HStack {
                Spacer()

                Button(action:
                    { isCentered = true }
                ) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.secondary) // .secondary - хороший адаптивный серый
                }
                .frame(width: 50, height: 50)
                .background(Color(.systemGray6)) // .systemGray6 - еще один хороший вариант для фона
                .clipShape(Rectangle())
                .cornerRadius(16)
                .shadow(radius: 2)
            }
        }
        .padding(.bottom, 65)
        .padding(.trailing, 14)
    }
}

// #Preview {
//    CenterButtonView(isCentrue)
// }
