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
                    selectedDepartment: $mapViewModel.selectedDepartment
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
                            // 1. Проверяем, существуют ли таблицы в базе данных
                            let tablesExist = await mapViewModel.dbViewModel.checkTablesExist()
                            
                            if tablesExist {
                                // 2a. Если да, то пользователь уже настроен. Загружаем данные карты.
                                await mapViewModel.loadMapData()
                            } else {
                                // 2b. Если нет, это новый пользователь. Показываем экран приветствия.
                                // Данные карты загрузятся после его закрытия (в блоке onDismiss).
                                showWelcomeScreen = true
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
