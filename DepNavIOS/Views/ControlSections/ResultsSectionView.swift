//
//  ResultsSectionView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 20.07.2025.
//

import SwiftUI

struct ResultsSectionView: View {
    @ObservedObject var mapViewModel: MapViewModel
    @Binding var detent: PresentationDetent

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
                            mapObject: marker,
                            currentDep: mapViewModel.selectedDepartment
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hideKeyboard()
                            mapViewModel.selectSearchResult(marker)
                            mapViewModel.selectedSearchResult = marker
                            withAnimation(.spring()) {
                                self.detent = .height(200)
                            }
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
