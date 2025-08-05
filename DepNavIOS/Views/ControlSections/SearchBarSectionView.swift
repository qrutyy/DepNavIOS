//
//  SearchBarSectionView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 20.07.2025.
//

import SwiftUI

struct SearchBarSectionView: View {
    @ObservedObject var mapViewModel: MapViewModel
    @Binding var detent: PresentationDetent

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(LocalizedString("search_section_textfield", comment: "Textfield placeholder"), text: $mapViewModel.searchQuery                      
            )
            .submitLabel(.search)
            .onSubmit {
                mapViewModel.commitSearch()
                if mapViewModel.searchResults.isEmpty == false {
                    withAnimation(.spring()) {
                        detent = .height(200)
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
}
