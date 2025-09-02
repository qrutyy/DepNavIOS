//
//  CoordLoaderViewModel.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 29.06.2025.
//

import Foundation

@MainActor
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
        if mapDescriptions[fileName] != nil {
            print("CoordLoader: Description for '\(fileName)' is already loaded.")
            return
        }
        // Use unified Documents/Maps path
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let jsonURL = docs.appendingPathComponent("Maps").appendingPathComponent(fileName).appendingPathComponent("\(fileName).json")
        guard FileManager.default.fileExists(atPath: jsonURL.path) else {
            print("CoordLoader: Error: Could not find \(fileName).json in Documents/Maps/")
            return
        }
        do {
            let data = try Data(contentsOf: jsonURL)
            let decodedData = try JSONDecoder().decode(MapDescription.self, from: data)
            mapDescriptions[decodedData.internalName] = decodedData
            print("CoordLoader: Successfully loaded and cached map for '\(decodedData.internalName)'.")
        } catch {
            print("CoordLoader: Error decoding JSON from \(fileName).json: \(error)")
        }
    }
}
