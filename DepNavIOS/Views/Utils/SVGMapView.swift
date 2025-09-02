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

    func directoryTree(at url: URL, prefix: String = "") -> String {
        var result = ""
        let fileManager = FileManager.default

        guard let contents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            return result
        }

        for (index, item) in contents.enumerated() {
            let isLast = index == contents.count - 1
            let branch = isLast ? "└── " : "├── "
            result += prefix + branch + item.lastPathComponent + "\n"

            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: item.path, isDirectory: &isDir), isDir.boolValue {
                let newPrefix = prefix + (isLast ? "    " : "│   ")
                result += directoryTree(at: item, prefix: newPrefix)
            }
        }
        return result
    }

    var body: some View {
        let url = mapViewModel.currentMapSVGURL
        if url != nil {
            AdvSVGView(
                url: url!,
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
                print("SVGView: File 'Maps/\(mapViewModel.selectedDepartment)/floor\(mapViewModel.selectedFloor).svg' wasn't found.")
                print(directoryTree(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                ))
            }
        }
    }
}
