//
//  BottomSearchSheetView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 30.06.2025.
//

import SwiftUI

struct BottomSearchSheetView: View {
    let callOnSubmit: () -> Void
    let department: String
    @Binding var idToFind: String
    @StateObject var DBModel: DatabaseViewModel
    @ObservedObject var coordinateLoader: CoordinateLoader

    // MARK: - Main Body

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            searchBar
            ScrollView {
                VStack(spacing: 0) {
                    favoritesSection
                    mainContentSection
                }
            }
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Helper Views

    /// The search bar view at the top of the sheet.
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))

            TextField("Search Maps", text: $idToFind)
                .font(.system(size: 16))
                .onSubmit(callOnSubmit)

            if !idToFind.isEmpty {
                Button(action: {
                    idToFind = ""
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

    /// The section displaying favorite items in a grid.
    private var favoritesSection: some View {
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

    /// The main content area, showing either search results or recent searches.
    @ViewBuilder
    private var mainContentSection: some View {
        if !idToFind.isEmpty {
            resultsSection
        } else {
            recentsSection
        }
    }

    /// The view for displaying search results.
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Results")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.top, 16)

            LazyVStack(spacing: 0) {
                if !idToFind.isEmpty {
                    if DBModel.isLoading {
                        ProgressView("Loading data from database...").padding()
                    } else {
                        if searchResults.isEmpty {
                            Text("No results found")
                        }
                        ForEach(searchResults, id: \.id) { item in
                            SearchResultRow(
                                icon: getHistoryIconByType(objectTypeName: item.objectTypeName),
                                title: getFormattedTitle(objectTitle: item.objectTitle, objectTypeName: item.objectTypeName),
                                subtitle: item.objectDescription
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var searchResults: [HistoryModel] {
        if idToFind.isEmpty {
            return []
        }

        guard let mapDescription = coordinateLoader.mapDescriptions[department] else {
            return []
        }

        let searchText = idToFind.lowercased()
        var uniqueID = 0

        // Use `flatMap` to iterate through all floors and directly map matching markers to HistoryModel.
        let unsortedResults = mapDescription.floors.flatMap { floorData -> [HistoryModel] in
            // For each floor, filter its markers.
            let matchingMarkersOnThisFloor = floorData.markers.filter { marker in
                // Safely check optional titles.
                let titleMatch = (marker.ru.title?.lowercased().hasPrefix(searchText) ?? false) ||
                    (marker.en.title?.lowercased().hasPrefix(searchText) ?? false)

                let typeMatch = marker.type.displayName.lowercased().hasPrefix(searchText)

                let descriptionMatch = (marker.ru.description?.lowercased().hasPrefix(searchText) ?? false) ||
                    (marker.en.description?.lowercased().hasPrefix(searchText) ?? false)

                return titleMatch || typeMatch || descriptionMatch
            }

            // Now, map the found markers on THIS floor to HistoryModel, using the floorData.
            return matchingMarkersOnThisFloor.map { marker -> HistoryModel in
                uniqueID += 1

                return HistoryModel(
                    // Use the marker's own ID, assuming it's unique across the entire dataset.
                    id: uniqueID,
                    // CRITICAL FIX: Use the floor number from the current floorData.
                    floor: floorData.floor,
                    department: department,
                    objectTitle: marker.ru.title ?? marker.en.title ?? "Unknown",
                    objectDescription: marker.ru.description ?? marker.en.description ?? "",
                    objectTypeName: marker.type.displayName
                )
            }
        }
        return unsortedResults.sorted{
            ($0.objectTitle.lowercased(), $0.objectTypeName.lowercased()) < ($1.objectTitle.lowercased(), $1.objectTypeName.lowercased())
        }
    }

    /// The view for displaying recent searches.
    private var recentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recents")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            LazyVStack(spacing: 0) {
                if DBModel.isLoading {
                    ProgressView("Loading data from database...").padding()
                } else {
                    let historySize = DBModel.historyLength
                    if historySize != nil && historySize != 0 {
                        ForEach(0 ... min(5, historySize!), id: \.self) { (elementNumber: Int) in
                            let historyItem = DBModel.historyItems[historySize! - elementNumber]
                            SearchResultRow(
                                icon: getHistoryIconByType(objectTypeName: historyItem.objectTypeName),
                                title: getFormattedTitle(objectTitle: historyItem.objectTitle, objectTypeName: historyItem.objectTypeName),
                                subtitle: historyItem.objectDescription
                            )
                        }
                    } else {
                        Text("No recent searches")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func getFormattedTitle(objectTitle: String, objectTypeName: String) -> String {
        return "\(objectTypeName) \(objectTitle)"
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

struct FavoriteItemView: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let backgroundColor: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 60, height: 60)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(iconColor)
            }

            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct SearchResultRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                if subtitle == "" {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .onTapGesture {
            print("Tapped on \(title)")
        }
    }
}

#Preview() {
    SearchResultRow(icon: "person.circle", title: "John Doe", subtitle: "johndoe@example.com")
}
