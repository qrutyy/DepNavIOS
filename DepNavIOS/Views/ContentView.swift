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

    // ADDED: CoordinateLoader is now owned by the parent view.
    @StateObject private var coordinateLoader = CoordinateLoader()

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
                BottomSearchSheetView(callOnSubmit: findMarkerWithId, idToFind: $idToFind)
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
        // You can add an alert here if you want
        .alert("Объект не найден", isPresented: $isSearchAlertPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Объект с ID \"\(idToFind)\" не был найден на карте.")
        }
    }

    // This function now correctly works within ContentView's scope
    private func findMarkerWithId() {
        guard let mapDescription = coordinateLoader.mapDescriptions[selectedDepartment] else {
            print("Ошибка: Данные для факультета '\(selectedDepartment)' не загружены.")
            showNotFoundState()
            return
        }
        for floorData in mapDescription.floors { // numbers with first digit as floor num - can be optimised
            if let foundMarker = floorData.markers.first(where: {
                ($0.ru.title ?? "") == idToFind || ($0.en.title ?? "") == idToFind
            }) {
                print("Найден маркер для '\(idToFind)' на координатах: \(foundMarker.coordinate)")
                markerCoordinate = foundMarker.coordinate
                isBottomSheetPresented = true
                return
            } else {
                print("Объект с ID '\(idToFind)' не найден на этаже \(selectedFloor).")
            }
            showNotFoundState()
        }
    }

    private func showNotFoundState() {
        markerCoordinate = nil
        isSearchAlertPresented = true
        isBottomSheetPresented = true
    }
}

#Preview {
    ContentView()
}
