//
//  CoordLoaderViewModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 29.06.2025.
//

import Foundation

class CoordinateLoader: ObservableObject {
    // Renamed for clarity: this dictionary stores the entire map description.
    @Published var mapDescriptions: [String: MapDescription] = [:]

    init() {
        // This can be empty.
    }

    /// Loads the map description for a specific department. (filename == department)
    /// The 'floor' parameter seems unused if each JSON file contains all floors,
    /// so we assume the filename is based on the department's internal name.
    func load(fileName: String) {
        // Check if we have already loaded this map to avoid redundant work.
        // We use the department name as the key for our cache.
        if mapDescriptions[fileName] != nil {
            print("CoordLoader: Description for '\(fileName)' is already loaded.")
            return
        }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Maps/\(fileName)") else {
            print("CoordLoader: Error: Could not find \(fileName).json in the bundle.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode(MapDescription.self, from: data)

            // Using `DispatchQueue.main.async` is good practice when updating @Published properties from non-UI code.
            DispatchQueue.main.async {
                self.mapDescriptions[decodedData.internalName] = decodedData
                print("CoordLoader: Successfully loaded and cached map for '\(decodedData.internalName)'.")
            }
        } catch {
            print("CoordLoader: Error decoding JSON from \(fileName).json: \(error)")
        }
    }
}
