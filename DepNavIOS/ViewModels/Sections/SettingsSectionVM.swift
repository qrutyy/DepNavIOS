import Foundation
import Combine

@MainActor
final class SettingsSectionVM: ObservableObject {
    @Published var selectedLanguage: LanguageModel
    @Published var selectedDepartment: String

    private let mapViewModel: MapViewModel
    private let languageManager: LanguageManagerModel

    init(mapViewModel: MapViewModel, languageManager: LanguageManagerModel = .shared) {
        self.mapViewModel = mapViewModel
        self.languageManager = languageManager
        self.selectedLanguage = languageManager.currentLanguage
        self.selectedDepartment = mapViewModel.selectedDepartment
    }

    func setLanguage(_ lang: LanguageModel) {
        languageManager.setLanguage(lang)
        Bundle.setLanguage(lang.localeIdentifier)
        selectedLanguage = lang
    }

    func setDepartment(_ dep: String) {
        guard selectedDepartment != dep else { return }
        selectedDepartment = dep
        mapViewModel.selectedDepartment = dep
    }
}

