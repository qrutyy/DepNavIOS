//
//  BottomSearchSheetView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 30.06.2025.
//
import SwiftUI

struct BottomSearchSheetView: View {
    // ObservedObaject is used bc lifecycle of ViewModel is managed by the parental ContentView
    @ObservedObject var mapViewModel: MapViewModel

    @Binding var detent: PresentationDetent

    @State private var showMarkerSection = false
    @State private var displayDeleteFavoriteButton: Bool = false

    // MARK: - Main Body

    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.top, detent != .height(50) ? 15 : 35)
                .padding(.bottom, 15)

            ScrollView {
                VStack(spacing: 0) {
                    // НОВАЯ, БОЛЕЕ ЧИСТАЯ ЛОГИКА
                    if let marker = mapViewModel.getSelectedMarker() {
                        // Если есть выбранный маркер, показываем детали
                        markerSection(marker: marker)
                    } else if !mapViewModel.searchQuery.isEmpty {
                        // Если нет выбранного маркера, но есть текст поиска - показываем результаты
                        resultsSection
                    } else {
                        // Во всех остальных случаях - избранное и недавние
                        favoritesSection
                        recentsSection
                    }
                }
            }
            .onChange(of: mapViewModel.searchQuery) { newValue in
                Task {
                    if newValue == mapViewModel.searchQuery {
                        mapViewModel.updateSearchResults()
                    }
                }
            }
            .onChange(of: mapViewModel.markerCoordinate) { newCoord in
                if newCoord != nil {
                    hideKeyboard()
                    withAnimation {
                        self.detent = .height(50)
                    }
                }
            }

            .onChange(of: mapViewModel.selectedMarker) { newSelectedMarker in
                if newSelectedMarker != "" {
                    withAnimation(.spring()) {
                        self.detent = .medium // или .large, как вам нужно
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Helper Views

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search Objects", text: $mapViewModel.searchQuery, onEditingChanged: { isEditing in
                withAnimation(.spring()) {
                    if isEditing {
                        self.detent = .large
                    }
                }
            })
            .submitLabel(.search)
            .onSubmit {
                mapViewModel.commitSearch()
                if mapViewModel.searchResults != [] {
                    withAnimation(.spring()) {
                        self.detent = .height(50)
                    }
                }
            }

            if !mapViewModel.searchQuery.isEmpty {
                Button(action: {
                    mapViewModel.searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                // .butt onStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Favourites")
                    .font(.title2.bold())
                    
                Spacer()
                if (mapViewModel.dbViewModel.favoriteItems.count != 0) {
                    Button("Clear") {
                        mapViewModel.dbViewModel.clearAllFavorites()
                    }
                    .font(.subheadline)
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal, 16)
            if (mapViewModel.dbViewModel.favoriteItems.count == 0) {
                VStack {
                    HStack {
                        Text("No objects in favorites")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                }
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                    ForEach(mapViewModel.dbViewModel.favoriteItems) { mapObject in
                        ZStack {
                            
                            FavoriteItemView(icon: getMapObjectIconByType(objectTypeName: mapObject.objectTypeName), title: mapObject.objectTitle, subtitle: mapObject.objectDescription, iconColor: .blue)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Telling ViewModel that user has selected the marker
                                    mapViewModel.selectSearchResult(mapObject.toInternalMarkerModel(mapDescription: mapViewModel.currentMapDescription)!)
                                }
                                .onLongPressGesture(minimumDuration: 0.2, perform: {withAnimation { displayDeleteFavoriteButton = true}})
                            
                            if displayDeleteFavoriteButton {
                                CloseButton {
                                    mapViewModel.removeFavoriteItem(mapObject)
                                }
                                .offset(x: 22, y: -31)
                            }
                            
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 10)
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Results")
                    .font(.title2.bold())
                Spacer()
            }
            .padding([.top, .horizontal], 16)
            .padding(.bottom, 8)

            if mapViewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity, alignment: .center)
            } else if mapViewModel.searchResults.isEmpty {
                    HStack {
                        Text("No objects were found")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(mapViewModel.searchResults) { marker in
                        SearchResultRowView(
                            icon: getMapObjectIconByType(objectTypeName: marker.type.displayName),
                            title: marker.title,
                            subtitle: marker.description
                                ?? ""
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Telling ViewModel that user has selected the marker
                            mapViewModel.selectSearchResult(marker)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func markerSection(marker: InternalMarkerModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(getFormattedTitle(objectTitle: marker.title, objectTypeName: marker.type.displayName))
                    .font(.title2.bold())
                Spacer()

                CloseButton {
                    mapViewModel.clearSelectedMarker()
                    self.detent = .medium
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            HStack(spacing: 12) {
                Button(action: {
                    print("Get Directions to \(marker.title)")
                }) {
                    Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: {
                    print("Save \(marker.title) to favorites")
                    mapViewModel.addSelectedMarkerToDB(marker: marker)
                }) {
                    Label("Save", systemImage: "heart.fill")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var recentsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Recents")
                    .font(.title2.bold())
                Spacer()
                if !mapViewModel.dbViewModel.historyItems.isEmpty {
                    Button("Clear") {
                        mapViewModel.dbViewModel.clearAllHistory()
                    }
                    .font(.subheadline)
                    .buttonStyle(.borderless)
                }
            }
            .padding([.top, .horizontal], 16)
            .padding(.bottom, 8)

            if mapViewModel.dbViewModel.historyItems.isEmpty {
                Text("History is empty")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(mapViewModel.dbViewModel.historyItems.prefix(10)) { mapObject in
                        SearchResultRowView(
                            icon: getMapObjectIconByType(objectTypeName: mapObject.objectTypeName),
                            title: getFormattedTitle(objectTitle: mapObject.objectTitle, objectTypeName: mapObject.objectTypeName),
                            subtitle: mapObject.objectDescription
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            mapViewModel.selectHistoryItem(mapObject)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func getFormattedTitle(objectTitle: String?, objectTypeName: String?) -> String {
        let type = objectTypeName ?? ""
        let title = objectTitle ?? ""
        return "\(type) \(title)".trimmingCharacters(in: .whitespaces)
    }

    private func getMapObjectIconByType(objectTypeName: String?) -> String {
        switch objectTypeName {
        case "Entrance": return "door.french.open"
        case "Room": return "door.left.hand.open"
        case "Stairs up": return "arrow.up.square"
        case "Stairs down": return "arrow.down.square"
        case "Stairs both": return "arrow.up.arrow.down.square"
        case "Elevator": return "arrow.up.and.down.square"
        case "WC man", "WC woman", "WC": return "toilet"
        default: return "mappin.circle"
        }
    }
}

#if canImport(UIKit)
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
#endif
