//
//  ContentView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import BottomSheet
import SwiftUI

struct ContentView: View {
    @State private var selectedFloor: Int = 1
    @State private var selectedDepartment: String = "spbu-mm"
    @State private var showWelcomeScreen = true

    @State private var idToFind: String = ""
    @State private var markerCoordinate: CGPoint?

    @State var bottomSheetPosition: BottomSheetPosition = .absolute(325)
    @State var isBottomSheetPresented: Bool = true

    @State private var isSearchAlertPresented: Bool = false
    @State private var searchElementCount: Int = 0

    @StateObject private var coordinateLoader = CoordinateLoader()

    @StateObject private var DBModel: DatabaseViewModel = .init()

    private let detents: Set<PresentationDetent> = [.height(55), .medium, .large]

    var body: some View {
        // Welcome Screen
        Button(action: {
            self.showWelcomeScreen = true
        }) {}
            .sheet(isPresented: $showWelcomeScreen) {
                WelcomeScreen(
                    showWelcomeScreen: $showWelcomeScreen,
                    selectedDepartment: $selectedDepartment
                )
            }

        ZStack(alignment: .topTrailing) {
            // CHANGED: Pass the coordinateLoader down to the map view.
            SVGMapView(
                floor: selectedFloor,
                department: selectedDepartment,
                markerCoordinate: $markerCoordinate,
                coordinateLoader: coordinateLoader
            )
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: $isBottomSheetPresented, onDismiss: { isBottomSheetPresented = true }) {
                BottomSearchSheetView(callOnSubmit: findMarkerWithId, department: selectedDepartment, idToFind: $idToFind, DBModel: DBModel, coordinateLoader: coordinateLoader)
                    .presentationDetents(detents)
                    .presentationCornerRadius(20)
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled()
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .presentationBackground(.clear)
            }

            VStack(spacing: 12) {
                ForEach([1, 2, 3, 4], id: \.self) { floor in
                    Button(action: {
                        selectedFloor = floor
                        removeMarker()
                    }) {
                        Text(String(floor))
                            .fontWeight(.medium)
                            .frame(width: 44, height: 44)
                            .background(selectedFloor == floor ? Color.blue : Color.clear)
                            .foregroundColor(selectedFloor == floor ? .white : .primary)
                            .cornerRadius(12)
                    }
                }
            }
            .background(.thinMaterial)
            .cornerRadius(12)
            .shadow(radius: 3)
            .padding(.top, 35)
            .padding(.trailing, 16)
        }
        .onAppear {
            // Load initial data when the view appears
            coordinateLoader.load(fileName: selectedDepartment)
        }
        .onChange(of: selectedDepartment) { newDepartment in
            // Reload data whenever the department changes
            coordinateLoader.load(fileName: newDepartment)
        }
        .onChange(of: isSearchAlertPresented) { _ in
            if !isBottomSheetPresented {
                isBottomSheetPresented = true
            }
        }
    }

    // DBModel is appended with new fully descriptive record for minimising repeative JSON parsing.
    private func findMarkerWithId() {
        var newDBHHistoryItem = HistoryModel()
        searchElementCount += 1

        guard let mapDescription = coordinateLoader.mapDescriptions[selectedDepartment] else {
            print("findMarkerWithId: Data for '\(selectedDepartment)' department isn' loaded.")
            showNotFoundState()
            return
        }

        for floorData in mapDescription.floors { // numbers with first digit as floor num - can be optimised
            if let foundMarker = floorData.markers.first(where: {
                ($0.ru.title ?? "") == idToFind || ($0.en.title ?? "") == idToFind
            }) {
                print("findMarkerWithId: marker with id = '\(idToFind)' was found on: \(foundMarker.coordinate)")
                markerCoordinate = foundMarker.coordinate
                isBottomSheetPresented = true
                selectedFloor = floorData.floor
                newDBHHistoryItem = HistoryModel(
                    id: searchElementCount,
                    floor: floorData.floor,
                    department: selectedDepartment,
                    objectTitle: foundMarker.ru.title ?? foundMarker.en.title ?? "",
                    objectDescription: foundMarker.ru.description ?? foundMarker.en.description ?? "",
                    objectTypeName: foundMarker.type.displayName
                )
                DBModel.addHistoryItem(newDBHHistoryItem)
                return
            }
        }

        newDBHHistoryItem = HistoryModel(
            id: searchElementCount,
            floor: nil,
            department: nil,
            objectTitle: idToFind,
            objectDescription: nil,
            objectTypeName: nil
        )
        DBModel.addHistoryItem(newDBHHistoryItem)

        print("findMarkerWithId: Error: object with id \(idToFind) not found in data for faculty '\(selectedDepartment)'.")
        showNotFoundState()
    }

    private func removeMarker() {
        markerCoordinate = nil
        idToFind = "" // mb ux will be better without
        isBottomSheetPresented = true
    }

    private func showNotFoundState() {
        removeMarker()
        isSearchAlertPresented = true
    }
}

#Preview {
    ContentView()
}
