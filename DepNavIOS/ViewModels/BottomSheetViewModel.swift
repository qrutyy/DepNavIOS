//
//  BottomSheetViewModel.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 30.06.2025.
//

import Combine
import SwiftUI

@MainActor
class BottomSheetViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currentSheetContent: SheetContent = .main
    @Published var displayDeleteFavoriteButton: Bool = false
    // @Published var showMarkerSection: Bool = false

    // MARK: - Dependencies

    let mapViewModel: MapViewModel
    let languageManager: LanguageManagerModel

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

    init(mapViewModel: MapViewModel, languageManager: LanguageManagerModel = .shared) {
        self.mapViewModel = mapViewModel
        self.languageManager = languageManager
        setupObservers()
    }

    // MARK: - Private Methods

    func setupObservers() {
        // Live search and content switch
        mapViewModel.$searchQuery
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.mapViewModel.updateSearchResults()
                self.updateSheetContent()
            }
            .store(in: &cancellables)

        // Switch to marker section on selection
        mapViewModel.$selectedSearchResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self else { return }
                if result != nil {
                    self.showMarkerSection()
                } else {
                    self.updateSheetContent()
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

    func showSettings() { currentSheetContent = .settings }

    func showMain() {
        currentSheetContent = .main
        updateDetentForMain()
    }

    func showMarkerSection() { currentSheetContent = .selMarker }

    func updateDetentForMain() { /* detent handled at View level */ }

    func selectSearchResult(_ marker: InternalMarkerModel) {
        mapViewModel.selectSearchResult(marker)
        showMarkerSection()
    }
}
