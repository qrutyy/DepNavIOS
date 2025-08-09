//
//  FavoriteSectionView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 20.07.2025.
//

import SwiftUI

struct FavoriteSectionView: View {
    @ObservedObject var mapViewModel: MapViewModel
    @StateObject private var vm: FavoritesSectionVM
    @Binding var displayDeleteFavoriteButton: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(LocalizedString("favorite_section_title", comment: "Title of the favorites section"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.leading, 16)
                    .padding(.top, 10)

                Spacer()
                if !vm.isEmpty {
                    Button(LocalizedString("generic_clear_button", comment: "Generic clear button")) {
                        vm.clearFavorites()
                    }
                    .font(.subheadline)
                    .buttonStyle(.borderless)
                    .padding(.top, 10)
                    .padding(.trailing, 16)
                }
            }
            .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 12) {
                if vm.isEmpty {
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
                        ForEach(vm.favoriteItems) { item in
                            ZStack {
                                FavoriteItemView(icon: getMapObjectIconByType(objectTypeName: item.type.displayName), title: item.title, subtitle: item.description ?? "", type: item.type.displayName, iconColor: .blue)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        vm.select(item)
                                    }
                                    .onLongPressGesture(minimumDuration: 0.2, perform: { withAnimation { displayDeleteFavoriteButton = true }})

                                if displayDeleteFavoriteButton {
                                    CloseButtonView {
                                        vm.remove(item)
                                    }
                                    .offset(x: 22, y: -45)
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
    init(mapViewModel: MapViewModel, displayDeleteFavoriteButton: Binding<Bool>) {
        self._mapViewModel = ObservedObject(wrappedValue: mapViewModel)
        self._displayDeleteFavoriteButton = displayDeleteFavoriteButton
        _vm = StateObject(wrappedValue: FavoritesSectionVM(mapViewModel: mapViewModel))
    }
}
