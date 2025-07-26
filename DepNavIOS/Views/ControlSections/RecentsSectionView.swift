//
//  RecentsSectionView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 20.07.2025.
//

import SwiftUI

struct RecentsSectionView: View {
    @ObservedObject var mapViewModel: MapViewModel

    var body: some View {
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
                            let internalObject = mapObject.toInternalMarkerModel(mapDescription: mapViewModel.getMapDescriptionByDepartment(department: mapObject.department))
                            if internalObject != nil {
                                SearchResultRowView(
                                    mapObject: internalObject!,
                                    currentDep: mapObject.department
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
}
