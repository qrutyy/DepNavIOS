//
//  DepSelectionScreenViewModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 19.08.2025.
//

import SwiftUI

final class DepSelectionViewModel: ObservableObject {
    @Published var mapCodeInput: String = ""
    @Published var isLoading = false
    @Published var error: String?

    let auth = AuthService()
    @ObservedObject var session: SessionStore
    @ObservedObject var mapViewModel: MapViewModel

    init(session: SessionStore, mapViewModel: MapViewModel) { self.session = session; self.mapViewModel = mapViewModel }

    @MainActor
    func authorize() async {
        error = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let device = UIDevice.current
            let token = try await auth.auth(
                deviceName: device.name,
                userUUID: device.identifierForVendor?.uuidString ?? UUID().uuidString,
                deviceModel: device.model,
                priorityMode: "user"
            )
            session.token = token
        } catch {
            self.error = LocalizedString("authorisation_fail", comment: "Failed to authorise")
        }
    }

    @MainActor
    func checkMapExists() async -> Bool {
        let result: Bool
        error = nil
        print("Checking if map \(mapCodeInput) exists")
        do {
            result = await mapViewModel.checkMapExists(mapCode: mapCodeInput)
        }
        if !result {
            error = LocalizedString("map_existence_fail", comment: "Map does not exist")
        }
        return result
    }
}
