//
//  BottomSheetViewModel.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 30.06.2025.
//

import SwiftUI
import Combine

@MainActor
class BottomSheetViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentSheetContent: SheetContent = .main
    @Published var detent: PresentationDetent = .height(50)
    @Published var displayDeleteFavoriteButton: Bool = false
    // @Published var showMarkerSection: Bool = false
    
    // MARK: - Dependencies
    
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var languageManager: LanguageManagerModel
    
    // MARK: - Computed Properties
    
    var shouldShowResults: Bool {
        !mapViewModel.searchQuery.isEmpty
    }
    
    var shouldShowMarkerSection: Bool {
        mapViewModel.getSelectedMarker() != nil
    }
    
    var shouldShowFavoritesAndRecents: Bool {
        mapViewModel.searchQuery.isEmpty && mapViewModel.getSelectedMarker() == nil
    }
    
    // MARK: - Initialization
    
    init() {
        // Observers will be set up when View appears
    }
    
    // MARK: - Private Methods
    
    func setupObservers() {
        // When search query changes, update content
        mapViewModel.$searchQuery
            .sink { [weak self] _ in
                self?.updateSheetContent()
            }
            .store(in: &cancellables)
        
        // When selected search result changes, show marker section
        mapViewModel.$selectedSearchResult
            .sink { [weak self] result in
                if result != nil {
                    self?.showMarkerSection()
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    func updateSheetContent() {
        if shouldShowResults {
            currentSheetContent = .main
        } else if shouldShowMarkerSection {
            currentSheetContent = .selMarker
        } else {
            currentSheetContent = .main
        }
    }
    
    func showSettings() {
        currentSheetContent = .settings
        detent = .height(300)
    }
    
    func showMain() {
        currentSheetContent = .main
        updateDetentForMain()
    }
    
    func showMarkerSection() {
        currentSheetContent = .selMarker
        detent = .height(200)
    }
    
    func updateDetentForMain() {
        if shouldShowResults || shouldShowMarkerSection {
            detent = .height(200)
        } else {
            detent = .height(50)
        }
    }
    
    func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
    
    func selectSearchResult(_ marker: InternalMarkerModel) {
        hideKeyboard()
        mapViewModel.selectSearchResult(marker)
        showMarkerSection()
    }
} 
