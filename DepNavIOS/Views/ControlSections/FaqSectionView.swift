//
//  FaqSectionView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 20.07.2025.
//

import SwiftUI

enum SheetContent {
    case main
    case settings
    case selMarker
}

struct FaqSectionView: View {
    @Binding var currentSheetContent: SheetContent

    @Environment(\.openURL) var openURL
    var body: some View {
        HStack {
            Button(action: {
                print("Settings button tapped!")
                withAnimation {
                    currentSheetContent = .settings
                }
            }) {
                Image(systemName: "gearshape")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
            }
            .frame(width: 45, height: 45)
            .background(Color(red: 238 / 255, green: 238 / 255, blue: 240 / 255))
            .cornerRadius(12)
            
            Spacer().frame(width: 10)
            
            Button(action: {
                openURL(URL(string: "https://github.com/qrutyy/DepNavIOS")!)
            }) {
                Text(LocalizedString("faq_section_report", comment: "Report an issue")).frame(maxWidth: .infinity, alignment: .center).foregroundColor(.blue).padding()
            }
            .frame(width: 310, height: 45)
            .background(Color(red: 238 / 255, green: 238 / 255, blue: 240 / 255))
            .cornerRadius(12)
        }

        .padding(.horizontal, 10)
        .padding(.top, 30)
    }
}
