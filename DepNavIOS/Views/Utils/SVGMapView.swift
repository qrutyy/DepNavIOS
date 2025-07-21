//
//  SVGMapView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import SVGView
import SwiftUI

/// Just a middle handler for the AdvSVGView.
/// Incapsulates all in all MapView and handles the loading error.
/// May be appended with the better error screen (when the custom map loading will be implemented) TODO
struct SVGMapView: View {
    let floor: Int
    let department: String

    @Binding var markerCoordinate: CGPoint?
    let mapDescription: MapDescription
    @Binding var selectedMarker: String
    @Binding var isCentered: Bool
    @Binding var isZoomedOut: Bool

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        if let url = Bundle.main.url(forResource: "floor\(floor)", withExtension: "svg", subdirectory: "Maps/\(department)") {
            AdvSVGView(
                url: url,
                floor: floor,
                department: department,
                markerCoordinate: $markerCoordinate,
                mapDescription: mapDescription,
                selectedMarker: $selectedMarker,
                isCentered: $isCentered,
                isZoomedOut: $isZoomedOut
            )
            .onAppear {
                print("SVGView: layout for file 'Maps/\(department)/floor\(floor).svg'")
            }

        } else {
            VStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                Text(LocalizedString("map_not_found_message", comment: "Map isn't found"))
                    .font(.headline)
            }
            .onAppear {
                print("SVGView: File '\(department)/floor\(floor).svg' wasn't found.")
            }
        }
    }
}
