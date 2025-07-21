//
//  ResultsSectionView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 20.07.2025.
//

import SwiftUI

struct ResultsSectionView: View {
    @ObservedObject var mapViewModel: MapViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(LocalizedString("results_section_title", comment: "Title of the section showing search results"))
                .font(.headline)
                    .foregroundColor(.primary)
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
                            type: marker.type.displayName,
                            currentDep: mapViewModel.selectedDepartment,
                            floor: String(marker.floor)
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
}
