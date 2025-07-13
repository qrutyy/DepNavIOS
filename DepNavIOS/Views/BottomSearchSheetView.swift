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

    // MARK: - Main Body

    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.top, detent != .height(50) ? 15 : 35)
                .padding(.bottom, 15)

            ScrollView {
                VStack(spacing: 0) {
                    if !mapViewModel.searchQuery.isEmpty {
                        resultsSection
                    } else if mapViewModel.selectedMarker != "" {
                        markerSection
                    } else {
                        favoritesSection
                        recentsSection
                    }
                }
            }
        }
        .background(Color(.systemBackground))
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
                // .buttonStyle(.plain)
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
            Text("Favourites")
                .font(.title2.bold())
                .padding(.horizontal, 16)

            // TODO: Replace with actual data from the DB
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                FavoriteItemView(icon: "house.fill", title: "SE lab", subtitle: "7777", iconColor: .blue, backgroundColor: Color(.systemGray5))
                FavoriteItemView(icon: "briefcase.fill", title: "Work", subtitle: "Add", iconColor: .blue, backgroundColor: Color(.systemGray5))
                FavoriteItemView(icon: "location.fill", title: "Auditorium", subtitle: "Main building", iconColor: .white, backgroundColor: .red)
                FavoriteItemView(icon: "plus", title: "Add", subtitle: "", iconColor: .blue, backgroundColor: Color(.systemGray5))
            }
            .padding(.horizontal, 16)
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
                Text("No suggestions found.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                // TODO: opportunity to add custom markers
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(mapViewModel.searchResults) { marker in
                        SearchResultRowView(
                            icon: getHistoryIconByType(objectTypeName: marker.type.displayName),
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
    private var markerSection: some View {
        let marker = mapViewModel.selectedMarker
        if marker != "" {
            VStack(alignment: .leading, spacing: 0) {
                // Section Header
                HStack {
                    Text("Selected Location")
                        .font(.title2.bold())
                    Spacer()
                    Button("Clear") {}
                        .font(.subheadline)
                        .buttonStyle(.borderless)
                }
                .padding([.top, .horizontal], 16)
                .padding(.bottom, 8)

                HStack(spacing: 12) {
                    Button(action: {
                        print("Get Directions to \(marker)")
                    }) {
                        Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: {
                        print("Save \(marker) to favorites")
                        mapViewModel.addSelectedMarkerToDB()
                    }) {
                        Label("Save", systemImage: "heart.fill")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
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
                    ForEach(mapViewModel.dbViewModel.historyItems.prefix(10)) { historyItem in
                        SearchResultRowView(
                            icon: getHistoryIconByType(objectTypeName: historyItem.objectTypeName),
                            title: getFormattedTitle(objectTitle: historyItem.objectTitle, objectTypeName: historyItem.objectTypeName),
                            subtitle: historyItem.objectDescription
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            mapViewModel.selectHistoryItem(historyItem)
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

    private func getHistoryIconByType(objectTypeName: String?) -> String {
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
