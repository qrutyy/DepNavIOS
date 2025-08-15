//
//  RecentsSectionView.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 20.07.2025.
//

import SwiftUI

struct RecentsSectionView: View {
    @ObservedObject var mapViewModel: MapViewModel
    @StateObject private var vm: RecentsSectionVM

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(LocalizedString("recents_section_title", comment: "Recents section title"))
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.leading, 16)
                    .padding(.top, 10)
                Spacer()
                if !vm.isEmpty {
                    Button(LocalizedString("generic_clear_button", comment: "Generic clear button")) {
                        vm.clearHistory()
                    }
                    .font(.subheadline)
                    .buttonStyle(.borderless)
                    .padding(.top, 10)
                    .padding(.trailing, 16)
                }
            }
            .padding(.horizontal, 16)

            VStack(alignment: .leading, spacing: 0) {
                if vm.isEmpty {
                    Text(LocalizedString("empty_history_list", comment: "History is empty"))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.recentItems) { item in
                            SearchResultRowView(
                                mapObject: item,
                                currentDep: item.department
                            )
                            .contentShape(Rectangle())
                            .onTapGesture { vm.select(item: item) }
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

    init(mapViewModel: MapViewModel) {
        _mapViewModel = ObservedObject(wrappedValue: mapViewModel)
        _vm = StateObject(wrappedValue: RecentsSectionVM(mapViewModel: mapViewModel))
    }
}
