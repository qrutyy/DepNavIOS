//
//  WelcomeScreenView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 29.06.2025.
//

import SwiftUI

struct WelcomeScreen: View {
    @Binding var showWelcomeScreen: Bool
    @Binding var selectedDepartment: String
    @Binding var selectedMapType: String
    @State private var showDepartmentSelection = false

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Spacer()
                Text(LocalizedString("welcome_screen_title", comment: "Welcome message"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                Spacer()
                Spacer()

                VStack(spacing: 26) {
                    FeatureCell(
                        image: "text.badge.checkmark",
                        title: LocalizedString("welcome_screen_f1_title", comment: "Find Your Way"),
                        subtitle: LocalizedString("welcome_screen_f1_subtitle", comment: "Quickly locate rooms and services across your faculty."),
                        color: .green
                    )

                    FeatureCell(
                        image: "map.fill",
                        title: LocalizedString("welcome_screen_f2_title", comment: "Explore the Campus"),
                        subtitle: LocalizedString("welcome_screen_f2_subtitle", comment: "Discover faculty maps — simple and clear."),
                        color: .blue
                    )

                    FeatureCell(
                        image: "plus.circle.fill",
                        title: LocalizedString("welcome_screen_f3_title", comment: "Add Your Faculty"),
                        subtitle: LocalizedString("welcome_screen_f3_subtitle", comment: "Easily import and use custom maps of your faculty."),
                        color: .orange
                    )
                }
                .padding(.leading)

                Spacer()
                Spacer()

                Button(action: {
                    showDepartmentSelection = true
                }) {
                    HStack {
                        Spacer()
                        Text( LocalizedString("generic_continue_button", comment: "Generic continue button"))
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .frame(height: 50)
                .background(Color.blue)
                .cornerRadius(15)
            }
            .padding()
            .sheet(isPresented: $showDepartmentSelection) {
                DepartmentSelectionScreen(showDepartmentSelection: $showDepartmentSelection, showWelcomeScreen: $showWelcomeScreen, selectedMapType: $selectedMapType, selectedDepartment: $selectedDepartment)
            }
        }
    }
}

struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen(showWelcomeScreen: .constant(true), selectedDepartment: .constant("spbu-mm"), selectedMapType: .constant(""))
    }
}
