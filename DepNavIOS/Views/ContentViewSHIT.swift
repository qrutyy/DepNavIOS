//
//  ContentViewSHIT.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 23.06.2025.
//

import BottomSheet
import SwiftUI

struct ContentViewRefactored: View {
    @StateObject private var mapViewModel = MapViewModel()
    @State private var showWelcomeScreen = true
    @State private var isBottomSheetPresented = true

    private let detents: Set<PresentationDetent> = [.height(55), .medium, .large]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Map View
            SVGMapView(
                floor: mapViewModel.selectedFloor,
                department: mapViewModel.selectedDepartment,
                markerCoordinate: $mapViewModel.markerCoordinate,
                coordinateLoader: mapViewModel.coordinateLoader
            )
            .edgesIgnoringSafeArea(.all)

            // Floor Selection Buttons
            FloorSelectionView(
                selectedFloor: $mapViewModel.selectedFloor,
                onFloorChange: { floor in
                    mapViewModel.changeFloor(floor)
                }
            )

            // Welcome Screen Button
            WelcomeButton(showWelcomeScreen: $showWelcomeScreen)
        }
        .sheet(isPresented: $showWelcomeScreen) {
            WelcomeScreen(
                showWelcomeScreen: $showWelcomeScreen,
                selectedDepartment: $mapViewModel.selectedDepartment
            )
        }
        .sheet(isPresented: $isBottomSheetPresented, onDismiss: { isBottomSheetPresented = true }) {
            BottomSearchSheetViewRefactored(
                mapViewModel: mapViewModel,
                isPresented: $isBottomSheetPresented
            )
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
            Task {
                await mapViewModel.loadMapData()
            }
        }
        .alert("Ошибка", isPresented: .constant(mapViewModel.errorMessage != nil)) {
            Button("OK") {
                mapViewModel.errorMessage = nil
            }
        } message: {
            Text(mapViewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Supporting Views

struct FloorSelectionView: View {
    @Binding var selectedFloor: Int
    let onFloorChange: (Int) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach([1, 2, 3, 4], id: \.self) { floor in
                Button(action: {
                    selectedFloor = floor
                    onFloorChange(floor)
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
}

struct WelcomeButton: View {
    @Binding var showWelcomeScreen: Bool

    var body: some View {
        Button(action: {
            showWelcomeScreen = true
        }) {
            // Empty button - just for triggering sheet
        }
    }
}

struct BottomSearchSheetViewRefactored: View {
    @ObservedObject var mapViewModel: MapViewModel
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            SearchBarView(
                searchQuery: $mapViewModel.searchQuery,
                onSubmit: {
                    Task {
                        await mapViewModel.searchMarker()
                    }
                }
            )
            ScrollView {
                VStack(spacing: 0) {
                    FavoritesSectionView()
                    SearchResultsSectionView(mapViewModel: mapViewModel)
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

struct SearchBarView: View {
    @Binding var searchQuery: String
    let onSubmit: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))

            TextField("Search Maps", text: $searchQuery)
                .font(.system(size: 16))
                .onSubmit(onSubmit)

            if !searchQuery.isEmpty {
                Button(action: {
                    searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.top, 25)
        .padding(.bottom, 20)
    }
}

struct FavoritesSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Favourites")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                FavoriteItemView(icon: "house.fill", title: "SE lab", subtitle: "7777", iconColor: .blue, backgroundColor: Color(.systemGray5))
                FavoriteItemView(icon: "briefcase.fill", title: "Work", subtitle: "Add", iconColor: .blue, backgroundColor: Color(.systemGray5))
                FavoriteItemView(icon: "location.fill", title: "Auditorium", subtitle: "Main building", iconColor: .white, backgroundColor: .red)
                FavoriteItemView(icon: "plus", title: "Add", subtitle: "", iconColor: .blue, backgroundColor: Color(.systemGray5))
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 10)
    }
}

struct SearchResultsSectionView: View {
    @ObservedObject var mapViewModel: MapViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Results")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.top, 16)

            LazyVStack(spacing: 0) {
                if mapViewModel.isLoading {
                    ProgressView("Loading data...").padding()
                } else if mapViewModel.searchQuery.isEmpty {
                    RecentsSectionView(mapViewModel: mapViewModel)
                } else {
                    if mapViewModel.searchResults.isEmpty {
                        Text("No results found")
                            .padding()
                    } else {
                        ForEach(mapViewModel.searchResults, id: \.id) { marker in
                            SearchResultRow(
                                icon: getHistoryIconByType(objectTypeName: marker.type.displayName),
                                title: "\(marker.type.displayName) \(marker.ru.title ?? marker.en.title ?? "")",
                                subtitle: marker.ru.description ?? marker.en.description ?? ""
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func getHistoryIconByType(objectTypeName: String) -> String {
        switch objectTypeName {
        case "Entrance": return "door.french.open"
        case "Room": return "door.left.hand.open"
        case "Stairs up": return "arrow.up.square"
        case "Stairs down": return "arrow.down.square"
        case "Stairs both": return "arrow.up.arrow.down.square"
        case "Elevator": return "arrow.up.and.down.square"
        case "WC man": return "figure.dress.line.vertical.figure"
        case "WC woman": return "figure.dress.line.vertical.figure"
        case "WC": return "toilet"
        case "Other": return "questionmark.circle"
        default: return "mappin.circle"
        }
    }
}

struct RecentsSectionView: View {
    @ObservedObject var mapViewModel: MapViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recents")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Text("No recent searches")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .padding()
        }
    }
}

#Preview {
    ContentViewRefactored()
}
