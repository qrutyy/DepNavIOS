//
//  SetupScreenView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 29.06.2025.
//

import SwiftUI

struct DepartmentSelectionScreen: View {
    @Binding var showDepartmentSelection: Bool
    @Binding var showWelcomeScreen: Bool
    @Binding var selectedDepartment: String

    var body: some View {
        ZStack {
            // Blurred background
            BlurView(style: .systemMaterial)
                .edgesIgnoringSafeArea(.all)

            // Centered selection window
            VStack(spacing: 20) {
                Text("Select Department")
                    .font(.headline)
                    .foregroundColor(.primary)

                Picker("Department", selection: $selectedDepartment) {
                    Text("MM").tag("spbu-mm")
                    Text("PF").tag("spbu-pf")
                    // Add more departments as needed
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                Button(action: {
                    // Update the selected department and dismiss
                    showDepartmentSelection = false
                    showWelcomeScreen = false
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
            .frame(width: 300, height: 200)
            .background(Color(.systemBackground).opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 10)
        }
    }
}

// BlurView to create the blurred background
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context _: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context _: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct DepartmentSelectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        DepartmentSelectionScreen(showDepartmentSelection: .constant(true), showWelcomeScreen: .constant(true), selectedDepartment: .constant(""))
    }
}
