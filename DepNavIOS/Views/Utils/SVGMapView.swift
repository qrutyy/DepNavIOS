//
//  SVGMapView.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 23.06.2025.
//

import SVGView
import SwiftUI

/// Just a middle handler for the AdvSVGView.
/// Incapsulates all in all MapView and handles the loading error.
/// May be appended with the better error screen (when the custom map loading will be implemented) TODO
struct SVGMapView: View {
    @ObservedObject var mapViewModel: MapViewModel

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        if let url = mapViewModel.currentMapSVGURL {
            AdvSVGView(
                url: url,
                mapViewModel: mapViewModel
            )
            .onAppear {
                print("SVGView: layout for file 'Maps/\(mapViewModel.selectedDepartment)/floor\(mapViewModel.selectedFloor).svg'")
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
                print("SVGView: File '\(mapViewModel.selectedDepartment)/floor\(mapViewModel.selectedFloor).svg' wasn't found.")
            }
        }
    }
}
