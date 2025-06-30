//
//  ContentView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import SwiftUI
import BottomSheet

struct ContentView: View {
    @State private var selectedFloor: String = "1"
    @State private var selectedDepartment: String = "spbu-mm"
    @State private var showWelcomeScreen = true

    @State private var idToFind: String = ""
    @State private var markerCoordinate: CGPoint?
    @StateObject private var coordinateLoader = CoordinateLoader()
    
    @State var bottomSheetPosition: BottomSheetPosition = .absolute(325)
    @State var isBottomSheetPresented: Bool = true

    @State private var isSearchAlertPresented: Bool = false
    
    // Updated detents for Maps-like behavior
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
                SVGMapView(floor: selectedFloor, department: selectedDepartment, markerCoordinate: $markerCoordinate)
                    // The map should fill the available space
                    .edgesIgnoringSafeArea(.all)
                    .sheet(isPresented: $isBottomSheetPresented, onDismiss: {isBottomSheetPresented = true}) {
                        // Maps-style bottom sheet content
                        BottomSearchSheetView(callOnSubmit: findMarkerWithId, idToFind: $idToFind)
                            .presentationDetents(detents)
                            .presentationCornerRadius(20)
                            .presentationDragIndicator(.visible)
                            .interactiveDismissDisabled()
                            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                            .presentationBackground(.clear) // Optional: makes background transparent
                    }
                // .alert("Object with id: \(idToFind) wasn't found", isPresented: $isSearchAlertPresented, actions: {}, message: {})
                
                // Floor picker moved to the top right corner
                VStack(spacing: 12) {
                    ForEach(["1", "2", "3", "4"], id: \.self) { floor in
                        Button(action: {
                            selectedFloor = floor
                        }) {
                            Text(floor.capitalized)
                                .fontWeight(.medium)
                                .frame(width: 44, height: 44) // Consistent sizing for buttons
                                .background(selectedFloor == floor ? Color.blue : Color.clear)
                                .foregroundColor(selectedFloor == floor ? .white : .primary)
                                .cornerRadius(12)
                        }
                    }
                }
                
                
                .background(.thinMaterial) // Use a modern, blurred background for better visibility
                .cornerRadius(12)
                .shadow(radius: 3)
                .padding(.top, 35)      // Add padding from the top safe area
                .padding(.trailing, 16) // Add padding from the right edge
                
                
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
        .onChange(of: isSearchAlertPresented) { _ in
                    // Ensure sheet stays open even after alert
                    if !isBottomSheetPresented {
                        isBottomSheetPresented = true
                    }
                }
    }

    private func findMarkerWithId() {
        if let room = coordinateLoader.coordinates[idToFind] {
            print(room.coordinate.y, room.coordinate.x)
            markerCoordinate = room.coordinate
            // idToFind = "" idk mb we shouldn't clear
            isBottomSheetPresented = true
        } else {
            markerCoordinate = nil
            print("Object with id: \(idToFind) not found in coordinates file.")
            isSearchAlertPresented = true
            isBottomSheetPresented = true
        }
    }
}

#Preview {
    ContentView()
}

