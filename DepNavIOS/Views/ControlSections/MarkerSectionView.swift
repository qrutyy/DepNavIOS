//
//  MarkerSectionView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 20.07.2025.
//

import SwiftUI

struct MarkerSectionView: View {
    var marker: InternalMarkerModel
    @ObservedObject var mapViewModel: MapViewModel
    @Binding var detent: PresentationDetent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(getFormattedTitle(objectTitle: marker.title, objectTypeName: stringFormatType(marker.type.displayName)))
                    .font(.title2.bold())
                Spacer()

                CloseButtonView {
                    mapViewModel.clearSelectedMarker()
                    detent = .height(50)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 8)

            if marker.description != nil && marker.description != "" {
                Text(marker.description!)
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
            }

            Text(((mapViewModel.selectedDepartment == "spbu-mm") ? LocalizedString("department_name_mm", comment: "Mathematics and Mechanics") : LocalizedString("department_name_ph", comment: "Faculty of Physics")) + ", " + "\(marker.floor) " + LocalizedString("map_vm_floor", comment: "Direction button from the marker section"))
                .font(.subheadline)
                .foregroundStyle(Color(.gray))
                .padding(.horizontal, 16)
                .padding(.bottom, 4)

            HStack(spacing: 12) {
                Button(action: {
                    print("Get Directions to \(marker.title)")
                }) {
                    Label(LocalizedString("marker_section_direction_button", comment: "Direction button from the marker section"), systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: {
                    if !mapViewModel.isMarkerInFavorites(markerID: marker.title) {
                        print("Save \(marker.title) to favorites")
                        mapViewModel.addSelectedMarkerToDB(marker: marker)
                    }
                }) {
                    if mapViewModel.isMarkerInFavorites(markerID: marker.title) {
                        Label(LocalizedString("added_to_favorites_button", comment: "Added to favorites button"), systemImage: "heart.fill")
                            .foregroundStyle(Color.gray)
                    } else {
                        Label(LocalizedString("add_to_favorites_button", comment: "Add to favorites button"), systemImage: "heart.fill")
                            .foregroundStyle(Color.blue)
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}
