//
//  CoordLoaderViewModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 29.06.2025.
//

import Foundation

class CoordinateLoader: ObservableObject {
    @Published var coordinates: [String: MarkerModel] = [:]

    init() {
        print()
    }

    func load(department: String, floor: String) {
        let fileName = "\(floor)-coords"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Maps/\(department)") else {
            print("CoordLoaderVM: Error: Could not find \(fileName).json")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode([MarkerModel].self, from: data)
            // reformat to a dict for faster by-key access
            coordinates = Dictionary(uniqueKeysWithValues: decodedData.map { ($0.id, $0) })
            print("CoordLoaderVM: Successfully loaded coordinates for \(fileName).json")
        } catch {
            print("CoordLoaderVM: Error decoding JSON: \(error)")
        }
    }
}
