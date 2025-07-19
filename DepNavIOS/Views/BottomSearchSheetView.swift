//
//  BottomSearchSheetView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 30.06.2025.
//
import SwiftUI

private enum SheetContent {
    case main
    case settings
}

struct BottomSearchSheetView: View {
    // ObservedObaject is used bc lifecycle of ViewModel is managed by the parental ContentView
    @ObservedObject var mapViewModel: MapViewModel

    @Binding var detent: PresentationDetent

    @State private var showMarkerSection = false
    @State private var displayDeleteFavoriteButton: Bool = false

    @State private var currentSheetContent: SheetContent = .main

    @ObservedObject var languageManager = LanguageManager.shared

    @Environment(\.openURL) var openURL

    // MARK: - Main Body

    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.top, detent != .height(50) ? 15 : 35)
                .padding(.bottom, 15)

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        switch currentSheetContent {
                        case .settings:
                            settingsSection()
                        case .main:
                            if let marker = mapViewModel.getSelectedMarker() {
                                markerSection(marker: marker)
                            } else if !mapViewModel.searchQuery.isEmpty {
                                resultsSection
                            } else {
                                favoritesSection
                                recentsSection
                            }

                            // This makes your FAQ/Settings buttons stick to the bottom
                            Spacer()

                            if detent != .height(50) {
                                faqSection
                            }
                        }
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
        .background(Color(red: 250 / 255, green: 250 / 255, blue: 249 / 255))
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    if let marker = mapViewModel.getSelectedMarker() {
                        markerSection(marker: marker)
                    } else if !mapViewModel.searchQuery.isEmpty {
                        resultsSection
                    } else {
                        favoritesSection
                        recentsSection
                    }
                }
            }

            // This makes your FAQ/Settings buttons stick to the bottom
            Spacer()

            if detent != .height(50) {
                faqSection
            }
        }
    }

    // MARK: - Helper Views

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(LocalizedString("search_section_textfield", comment: "Textfield placeholder"), text: $mapViewModel.searchQuery, onEditingChanged: { isEditing in
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
        .background(Color(red: 234 / 255, green: 234 / 255, blue: 236 / 255))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(LocalizedString("favorite_section_title", comment: "Title of the favorites section"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.leading, 16)
                    .padding(.top, 10)

                Spacer()
                if mapViewModel.dbViewModel.favoriteItems.count != 0 {
                    Button(LocalizedString("generic_clear_button", comment: "Generic clear button")) {
                        mapViewModel.dbViewModel.clearAllFavorites()
                    }
                    .font(.subheadline)
                    .buttonStyle(.borderless)
                    .padding(.top, 10)
                    .padding(.trailing, 16)
                }
            }
            .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 12) {
                if mapViewModel.dbViewModel.favoriteItems.count == 0 {
                    VStack {
                        HStack {
                            Text(LocalizedString("empty_favorites_list", comment: "Empty favorites list"))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    }
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), alignment: .leading, spacing: 16) {
                        ForEach(mapViewModel.dbViewModel.favoriteItems) { mapObject in
                            ZStack {
                                FavoriteItemView(icon: getMapObjectIconByType(objectTypeName: mapObject.objectTypeName), title: mapObject.objectTitle, subtitle: mapObject.objectDescription, iconColor: .blue)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        // Telling ViewModel that user has selected the marker
                                        mapViewModel.selectSearchResult(mapObject.toInternalMarkerModel(mapDescription: mapViewModel.currentMapDescription)!)
                                    }
                                    .onLongPressGesture(minimumDuration: 0.2, perform: { withAnimation { displayDeleteFavoriteButton = true }})

                                if displayDeleteFavoriteButton {
                                    CloseButtonView {
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
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(LocalizedString("results_section_title", comment: "Title of the section showing search results"))
                    .font(.title2.bold())
                Spacer()
            }
            .padding([.top, .horizontal], 16)
            .padding(.bottom, 8)

            if mapViewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity, alignment: .center)
            } else if mapViewModel.searchResults.isEmpty {
                HStack {
                    Text(LocalizedString("empty_results_message", comment: "Message to describe empty search results"))
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
                                ?? "",
                            type: marker.type.displayName
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Telling ViewModel that user has selected the marker
                            mapViewModel.selectSearchResult(marker)
                        }
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray.opacity(0.2)),
                            alignment: .bottom
                        )
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

                CloseButtonView {
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
                    Label(LocalizedString("marker_section_direction_button", comment: "Direction button from the marker section"), systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: {
                    if !mapViewModel.isMarkerInFavorites(markerID: marker.title) {
                        print("Save \(marker.title) to favorites")
                        mapViewModel.addSelectedMarkerToDB(marker: marker)
                    }
                }) {
                    if mapViewModel.isMarkerInFavorites(markerID: marker.title) {
                        Label(LocalizedString("added_to_favorites_button", comment: "Added to favorites button"), systemImage: "heart.fill")
                            .foregroundStyle(Color.gray)
                    } else {
                        Label(LocalizedString("add_to_favorites_button", comment: "Add to favorites button"), systemImage: "heart.fill")
                            .foregroundStyle(Color.blue)
                    }
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
                Text(LocalizedString("recents_section_title", comment: "Recents section title"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.leading, 16)
                    .padding(.top, 10)
                Spacer()
                if !mapViewModel.dbViewModel.historyItems.isEmpty {
                    Button(LocalizedString("generic_clear_button", comment: "Generic clear button")) {
                        mapViewModel.dbViewModel.clearAllHistory()
                    }
                    .font(.subheadline)
                    .buttonStyle(.borderless)
                    .padding(.top, 10)
                    .padding(.trailing, 16)
                }
            }
            .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 0) {
                if mapViewModel.dbViewModel.historyItems.isEmpty {
                    Text(LocalizedString("empty_history_list", comment: "History is empty"))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(mapViewModel.dbViewModel.historyItems.prefix(10)) { mapObject in
                            SearchResultRowView(
                                icon: getMapObjectIconByType(objectTypeName: mapObject.objectTypeName),
                                title: mapObject.objectTitle,
                                subtitle: mapObject.objectDescription,
                                type: mapObject.objectTypeName
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                mapViewModel.selectHistoryItem(mapObject)
                            }

                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color.gray.opacity(0.2)),
                                alignment: .bottom
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    @ViewBuilder
    private func settingsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) { // Added spacing
            HStack {
                Text(LocalizedString("settings_section_title", comment: "Settings section title")).font(.title2.bold())
                Spacer()

                CloseButtonView {
                    withAnimation {
                        currentSheetContent = .main
                    }
                }
            }

            // Language switcher
            HStack(spacing: 12) {
                Text(LocalizedString("settings_language_title", comment: "Language switch"))
                Spacer()
                ForEach(Language.allCases) { lang in
                    Button(action: {
                        withAnimation {
                            languageManager.setLanguage(lang)
                            Bundle.setLanguage(lang.localeIdentifier)
                        }
                    }) {
                        Text(lang.displayName)
                            .fontWeight(languageManager.currentLanguage == lang ? .bold : .regular)
                            .foregroundColor(languageManager.currentLanguage == lang ? .blue : .primary)
                            .padding(6)
                            .background(languageManager.currentLanguage == lang ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 8)

            Text(LocalizedString("faq_section_made_by", comment: "Made with love by @qrutyy"))
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var faqSection: some View {
        HStack {
            Button(action: {
                print("Settings button tapped!")
                withAnimation {
                    currentSheetContent = .settings
                }
            }) {
                Image(systemName: "gearshape")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
            }
            .frame(width: 45, height: 45)
            .background(Color(red: 238 / 255, green: 238 / 255, blue: 240 / 255))
            .cornerRadius(12)
            Spacer().frame(width: 10)
            Button(action: {
                openURL(URL(string: "https://github.com/qrutyy/DepNavIOS")!)
            }) {
                Text(LocalizedString("faq_section_report", comment: "Report an issue")).frame(maxWidth: .infinity, alignment: .center).foregroundColor(.blue).padding()
            }
            .frame(width: 310, height: 45)
            .background(Color(red: 238 / 255, green: 238 / 255, blue: 240 / 255))
            .cornerRadius(12)
        }

        .padding(.horizontal, 10)
        .padding(.top, 30)
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
