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
    @StateObject private var sheetVM: BottomSheetViewModel
    @State private var displayDeleteFavoriteButton: Bool = false
    @ObservedObject var languageManager = LanguageManagerModel.shared

    var body: some View {
        VStack(spacing: 0) {
            SearchBarSectionView(mapViewModel: mapViewModel, detent: $detent)
                .padding(.top, detent != .height(50) ? 15 : 35)
                .padding(.bottom, 15)

            mainContentSheet
                .onChange(of: mapViewModel.searchQuery) { newValue in
                    Task {
                        if newValue == mapViewModel.searchQuery {
                            mapViewModel.updateSearchResults()
                            // mapViewModel.selectedMarker = ""
                        }
                    }
                }

                .onChange(of: mapViewModel.selectedMarker) { newSelectedMarker in
                    if newSelectedMarker != "" {
                        withAnimation(.spring()) {
                            sheetVM.showMain()
                            detent = .height(200)
                        }
                    }
                }
        }
        .background(Color(red: 250 / 255, green: 250 / 255, blue: 249 / 255))
    }

    private var mainContentSheet: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    switch sheetVM.currentSheetContent {
                    case .settings:
                        SettingsSectionView(mapViewModel: mapViewModel, currentSheetContent: $sheetVM.currentSheetContent)
                            .onAppear {
                                withAnimation {
                                    detent = .height(300)
                                }
                            }

                    case .main:
                        if !mapViewModel.searchQuery.isEmpty {
                            withAnimation {
                                ResultsSectionView(mapViewModel: mapViewModel, detent: $detent)
                            }
                        } else if let marker = mapViewModel.getSelectedMarker() {
                            withAnimation {
                                MarkerSectionView(marker: marker, mapViewModel: mapViewModel, detent: $detent)
                            }
                        } else {
                            FavoriteSectionView(mapViewModel: mapViewModel, displayDeleteFavoriteButton: $displayDeleteFavoriteButton)
                            RecentsSectionView(mapViewModel: mapViewModel)
                            if detent != .height(50) {
                                FaqSectionView(currentSheetContent: $sheetVM.currentSheetContent)
                            }
                        }

                        // This makes your FAQ/Settings buttons stick to the bottom
                        Spacer()

                    case .selMarker:
                        if let marker = mapViewModel.getSelectedMarker() {
                            withAnimation {
                                MarkerSectionView(marker: marker, mapViewModel: mapViewModel, detent: $detent)
                            }
                        }
                    }
                }
            }
        }
    }

    init(mapViewModel: MapViewModel, detent: Binding<PresentationDetent>) {
        _mapViewModel = ObservedObject(wrappedValue: mapViewModel)
        _detent = detent
        _sheetVM = StateObject(wrappedValue: BottomSheetViewModel(mapViewModel: mapViewModel))
    }
}

#if canImport(UIKit)
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
#endif
