//
//  ContentView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showWelcomeScreen = false
    @State private var isBottomSheetPresented = true
    @StateObject private var mapViewModel = MapViewModel()

    // Basic set of detents for the Bottom sheet.
    private let searchSheetDetents: Set<PresentationDetent> = [.height(50), .medium, .large]
    @State private var selectedDetent: PresentationDetent = .height(50)

    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false

    @State private var isCheckingSetup = true

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if mapViewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
                    .zIndex(10)
            }
            if mapViewModel.currentMapDescription != nil {
                SVGMapView(
                    floor: mapViewModel.selectedFloor,
                    department: mapViewModel.selectedDepartment,
                    markerCoordinate: $mapViewModel.markerCoordinate,
                    mapDescription: mapViewModel.currentMapDescription!, selectedMarker: $mapViewModel.selectedMarker
                )
                .edgesIgnoringSafeArea(.all)

                FloorSelectionView(
                    selectedFloor: $mapViewModel.selectedFloor,
                    onFloorChange: { floor in
                        mapViewModel.changeFloor(floor)
                    }, availableFloors: mapViewModel.availableFloors
                )

            } else {
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        if !showWelcomeScreen {
                            Task {
                                await mapViewModel.loadMapData()
                            }
                        }
                    }
            }
        }

        .sheet(isPresented: $showWelcomeScreen) {
            Task {
                await mapViewModel.loadMapData()
            }
        } content: {
            WelcomeScreen(
                showWelcomeScreen: $showWelcomeScreen,
                selectedDepartment: $mapViewModel.selectedDepartment, selectedMapType: $mapViewModel.selectedMapType
            )
        }
        .sheet(isPresented: $isBottomSheetPresented) {
            BottomSearchSheetView(mapViewModel: mapViewModel, detent: $selectedDetent)
                .presentationDetents(searchSheetDetents, selection: $selectedDetent)
                .presentationCornerRadius(20)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationBackground(.clear)
        }
        .onAppear {
            Task {
                if !hasLaunchedBefore {
                    showWelcomeScreen = true
                    hasLaunchedBefore = true
                } else {
                    await mapViewModel.loadMapData()
                }
            }
        }
        .onChange(of: mapViewModel.selectedDepartment) { _ in
            if !showWelcomeScreen {
                Task {
                    await mapViewModel.loadMapData()
                }
            }
        }
    }
}
