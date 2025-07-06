//
//  ContentView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showWelcomeScreen = true
    
    // ИЗМЕНЕНИЕ: Изначально нижний sheet НЕ должен быть показан.
    @State private var isBottomSheetPresented = false

    @StateObject private var mapViewModel = MapViewModel()

    private let detents: Set<PresentationDetent> = [.height(85), .medium, .large]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // ... (индикатор загрузки и SVGMapView остаются без изменений) ...
             if mapViewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
                    .zIndex(10)
            }
            if (mapViewModel.currentMapDescription != nil) {
                SVGMapView(
                    floor: mapViewModel.selectedFloor,
                    department: mapViewModel.selectedDepartment,
                    markerCoordinate: $mapViewModel.markerCoordinate,
                    mapDescription: mapViewModel.currentMapDescription!
                )
                .edgesIgnoringSafeArea(.all)
                FloorSelectionView(
                    selectedFloor: $mapViewModel.selectedFloor,
                    onFloorChange: { floor in
                        mapViewModel.changeFloor(floor)
                    }, availableFloors: mapViewModel.availableFloors
                )
            } else {
         
                                Color(.systemGroupedBackground) // Фоновый цвет, чтобы не было черного экрана
                                    .edgesIgnoringSafeArea(.all)
                                    .onAppear {
                                        // Если по какой-то причине мы оказались здесь без WelcomeScreen,
                                        // можно добавить защитную логику.
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
                isBottomSheetPresented = true
            }
        } content: {
            WelcomeScreen(
                showWelcomeScreen: $showWelcomeScreen,
                selectedDepartment: $mapViewModel.selectedDepartment
            )
        }
        // Этот sheet для BottomSearchSheetView.
        // Он привязан к isBottomSheetPresented и появится, когда нужно.
        .sheet(isPresented: $isBottomSheetPresented) {
            BottomSearchSheetView(mapViewModel: mapViewModel)
                .presentationDetents(detents)
                .presentationCornerRadius(20)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationBackground(.clear)
        }
        .onAppear {
                Task {
                    await mapViewModel.loadMapData()
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
