//
//  SVGMapView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import SVGView
import SwiftUI

struct SVGMapView: View {
    let floor: Int
    let department: String

    @Binding var markerCoordinate: CGPoint?

    let coordinateLoader: CoordinateLoader

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        if let url = Bundle.main.url(forResource: "floor\(floor)", withExtension: "svg", subdirectory: "Maps/\(department)") {
            AdvSVGView(
                url: url,
                floor: floor,
                department: department,
                markerCoordinate: $markerCoordinate,
                coordinateLoader: coordinateLoader
            )
            .onAppear {
                print("SVGView: layout for file 'Maps/\(department)/floor\(floor).svg'")
            }

        } else {
            VStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                Text("Map isn't found")
                    .font(.headline)
                Text("File '\(department)/floor\(floor).svg' doesn't exist.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .onAppear {
                print("SVGView: File '\(department)/floor\(floor).svg' wasn't found.")
            }
        }
    }
}
