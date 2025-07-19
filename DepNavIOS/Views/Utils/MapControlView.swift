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
                        .foregroundStyle(Color(red: 210/255, green: 210/255, blue: 212/255))
                }
                .frame(width: 50, height: 50)
                .background(Color(red: 250/255, green: 250/255, blue: 249/255))
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
                        .foregroundStyle(Color(red: 210/255, green: 210/255, blue: 212/255))

                }
                .frame(width: 50, height: 50)
                
                .background(Color(red: 250/255, green: 250/255, blue: 249/255))

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
