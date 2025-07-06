//
//  BottomSearchSheetView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 30.06.2025.
//
import SwiftUI

struct BottomSearchSheetView: View {
    // ИЗМЕНЕНИЕ: Используем @ObservedObject, так как жизненный цикл этой ViewModel
    // управляется родительским ContentView.
    @ObservedObject var mapViewModel: MapViewModel
    
    // ИЗМЕНЕНИЕ: Убрал isPresented, так как он не используется внутри View.
    // Состоянием управляет родительский ContentView.

    // MARK: - Main Body

    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.top, 25)
                .padding(.bottom, 20)

            ScrollView {
                VStack(spacing: 0) {
                    if mapViewModel.searchQuery.isEmpty {
                        // Показываем избранное и недавние, если поиск пуст
                        favoritesSection
                        recentsSection
                    } else {
                        // Показываем результаты поиска, если что-то введено
                        resultsSection
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        
        .onChange(of: mapViewModel.searchQuery) { newValue in
            Task {
                if newValue == mapViewModel.searchQuery {
                    await mapViewModel.searchMarkers()
                }
            }
        }
    }

    // MARK: - Helper Views

    /// Панель поиска
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search Maps", text: $mapViewModel.searchQuery)
                .submitLabel(.search)
                .onSubmit {
                    Task { await mapViewModel.searchMarkers() }
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

    /// Секция "Избранное"
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favourites")
                .font(.title2.bold())
                .padding(.horizontal, 16)

            // TODO: Заменить на реальные данные из ViewModel
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

    /// Секция результатов поиска
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
                        SearchResultRow(
                            icon: getHistoryIconByType(objectTypeName: marker.type.displayName),
                            title: marker.title,
                            subtitle: marker.description
                             ?? ""
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Сообщаем ViewModel, что пользователь выбрал маркер
                            mapViewModel.selectMarker(marker)
                        }
                    }
                }
            }
        }
    }

    /// Секция недавних поисков
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

            // ИЗМЕНЕНИЕ: Используем `historyItems` из вложенной `dbViewModel`
            if mapViewModel.dbViewModel.historyItems.isEmpty {
                Text("История поиска пуста")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(mapViewModel.dbViewModel.historyItems.prefix(10)) { historyItem in
                        SearchResultRow(
                            icon: getHistoryIconByType(objectTypeName: historyItem.objectTypeName),
                            title: getFormattedTitle(objectTitle: historyItem.objectTitle, objectTypeName: historyItem.objectTypeName),
                            subtitle: historyItem.objectDescription
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Сообщаем ViewModel, что пользователь выбрал элемент истории
                            mapViewModel.selectHistoryItem(historyItem)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func getFormattedTitle(objectTitle: String?, objectTypeName: String?) -> String {
        // Защита от nil
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
