//
//  SettingsSectionView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 20.07.2025.
//
import SwiftUI

struct SettingsSectionView: View {
    @ObservedObject var mapViewModel: MapViewModel
    @Binding var currentSheetContent: SheetContent
    @StateObject private var vm: SettingsSectionVM

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            languageSection
            departmentSection
            footerSection
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var headerSection: some View {
        HStack {
            Text(LocalizedString("settings_section_title", comment: "Settings section title"))
                .font(.title2.bold())
            Spacer()
            CloseButtonView {
                withAnimation {
                    currentSheetContent = .main
                }
            }
        }
    }

    private var languageSection: some View {
        HStack(spacing: 12) {
            Text(LocalizedString("settings_language_title", comment: "Language switch"))
            Spacer()
            ForEach(LanguageModel.allCases) { lang in
                Button(action: {
                    withAnimation {
                        vm.setLanguage(lang)
                    }
                }) {
                    Text(lang.displayName)
                        .fontWeight(vm.selectedLanguage == lang ? .bold : .regular)
                        .foregroundColor(vm.selectedLanguage == lang ? .blue : .primary)
                        .padding(6)
                        .background(vm.selectedLanguage == lang ? Color.blue.opacity(0.1) : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var departmentSection: some View {
        let departments: [(id: String, display: String)] = [
            ("spbu-mm", LocalizedString("settings_department_mm", comment: "MM department")),
            ("spbu-pf", LocalizedString("settings_department_pf", comment: "PF department")),
        ]

        return HStack(spacing: 12) {
            Text(LocalizedString("settings_department_title", comment: "Department switch"))
            Spacer()

            ForEach(departments, id: \.id) { dep in
                let isSelected = vm.selectedDepartment == dep.id

                Button(action: {
                    withAnimation {
                        vm.setDepartment(dep.id)
                    }
                }) {
                    Text(dep.display)
                        .fontWeight(isSelected ? .bold : .regular)
                        .foregroundColor(isSelected ? .blue : .primary)
                        .padding(6)
                        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var footerSection: some View {
        Text(LocalizedString("faq_section_made_by", comment: "Made with love by @qrutyy"))
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}

extension SettingsSectionView {
    init(mapViewModel: MapViewModel, currentSheetContent: Binding<SheetContent>) {
        _mapViewModel = ObservedObject(wrappedValue: mapViewModel)
        _currentSheetContent = currentSheetContent
        _vm = StateObject(wrappedValue: SettingsSectionVM(mapViewModel: mapViewModel))
    }
}
