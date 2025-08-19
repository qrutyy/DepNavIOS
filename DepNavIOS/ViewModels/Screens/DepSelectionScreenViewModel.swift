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

    init(session: SessionStore) { self.session = session }

    @MainActor
    func authorizeAndStore(mapCode: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let device = UIDevice.current
            let token = try await auth.auth(
                deviceName: device.name,
                userUUID: device.identifierForVendor?.uuidString ?? UUID().uuidString,
                deviceModel: device.model,
                priorityMode: "user",
                mapCode: mapCode
            )
            session.token = token
            session.mapCode = mapCode
            print("Entered map code \(mapCode) and received token \(token)")
        } catch {
            self.error = error.localizedDescription
        }
    }
}
