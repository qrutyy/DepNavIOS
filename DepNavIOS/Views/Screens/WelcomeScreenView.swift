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
                Text("Welcome to DepNav")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                Spacer()
                Spacer()

                VStack(spacing: 26) {
                    FeatureCell(
                        image: "text.badge.checkmark",
                        title: "Find Your Way",
                        subtitle: "Quickly locate rooms and services across your faculty.",
                        color: .green
                    )

                    FeatureCell(
                        image: "map.fill",
                        title: "Explore the Campus",
                        subtitle: "Discover faculty maps — simple and clear.",
                        color: .blue
                    )

                    FeatureCell(
                        image: "plus.circle.fill",
                        title: "Add Your Faculty",
                        subtitle: "Easily import and use custom maps of your faculty.",
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
                        Text("Continue")
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
