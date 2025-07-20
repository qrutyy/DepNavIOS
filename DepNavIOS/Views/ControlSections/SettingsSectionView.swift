//
//  SettingsSectionView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 20.07.2025.
//

import SwiftUI

struct SettingsSectionView : View {
    @Binding var currentSheetContent: SheetContent
    
    @ObservedObject var languageManager = LanguageManager.shared
    var body : some View {
        VStack(alignment: .leading, spacing: 16) { // Added spacing
            HStack {
                Text(LocalizedString("settings_section_title", comment: "Settings section title")).font(.title2.bold())
                Spacer()
                
                CloseButtonView {
                    withAnimation {
                        currentSheetContent = .main
                    }
                }
            }
            
            // Language switcher
            HStack(spacing: 12) {
                Text(LocalizedString("settings_language_title", comment: "Language switch"))
                Spacer()
                ForEach(Language.allCases) { lang in
                    Button(action: {
                        withAnimation {
                            languageManager.setLanguage(lang)
                            Bundle.setLanguage(lang.localeIdentifier)
                        }
                    }) {
                        Text(lang.displayName)
                            .fontWeight(languageManager.currentLanguage == lang ? .bold : .regular)
                            .foregroundColor(languageManager.currentLanguage == lang ? .blue : .primary)
                            .padding(6)
                            .background(languageManager.currentLanguage == lang ? Color.blue.opacity(0.1) : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 8)
            
            Text(LocalizedString("faq_section_made_by", comment: "Made with love by @qrutyy"))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)

    }
}
