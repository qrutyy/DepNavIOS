//
//  ContentView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedFloor: String = "floor1"
    @State private var selectedDepartment: String = "spbu-mm"
    @State private var showWelcomeScreen = true

    @State private var idToFind: String = ""
    @State private var markerCoordinate: CGPoint?
    @StateObject private var coordinateLoader = CoordinateLoader()

    @State private var isSearchAlertPresented: Bool = false

    var body: some View {
        VStack(spacing: 0) {
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

            HStack {
                TextField("Enter room number", text: $idToFind)
                    .frame(width: 300, height: 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit(findMarkerWithId) // Искать при нажатии Enter

                Button("Find", action: findMarkerWithId).alert("Object with id: \(idToFind) wasn't found", isPresented: $isSearchAlertPresented, actions: {}, message: {})
            }

            // Floor picker (should be reworked - dep from the files + change ui representation)
            Picker("Select Floor", selection: $selectedFloor) {
                Text("Floor 1").tag("floor1")
                Text("Floor 2").tag("floor2")
                Text("Floor 3").tag("floor3")
                Text("Floor 4").tag("floor4")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            SVGMapView(floor: selectedFloor, department: selectedDepartment, markerCoordinate: $markerCoordinate)
                .frame(height: 600)
                .border(Color.green, width: 2)
                .padding()
        }
        .onAppear {
            coordinateLoader.load(department: selectedDepartment, floor: selectedFloor)
        }
        // call load each time we change the department
        .onChange(of: selectedDepartment) { newDepartment in
            coordinateLoader.load(department: newDepartment, floor: selectedFloor)
            markerCoordinate = nil
            idToFind = ""
        }
        // it shouldnt be changed when switching the floors, bc it will change it to appropriate one by itself
    }

    private func findMarkerWithId() {
        if let room = coordinateLoader.coordinates[idToFind] {
            print(room.coordinate.y, room.coordinate.x)
            markerCoordinate = room.coordinate
            // idToFind = "" idk mb we shouldn't clear
        } else {
            markerCoordinate = nil
            print("Object with id: \(idToFind) not found in coordinates file.")
            isSearchAlertPresented = true
        }
    }
}

#Preview {
    ContentView()
}
