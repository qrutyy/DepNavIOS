//
//  SetupScreenView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 29.06.2025.
//

import SwiftUI

import SwiftUI

struct DepartmentSelectionScreen: View {
    @Binding var showDepartmentSelection: Bool
    @Binding var showWelcomeScreen: Bool
    @Binding var selectedMapType: String
    @Binding var selectedDepartment: String
    
    private var isContinueButtonDisabled: Bool {
            selectedMapType == "custom"
        }

    var body: some View {
        ZStack {
            // Blurred background
            BlurView(style: .systemMaterial)
                .edgesIgnoringSafeArea(.all)

            // Centered selection window
            VStack(spacing: 20) {
                Text("Select map type")
                    .font(.headline)
                    .foregroundColor(.primary)

                Picker("Map type", selection: $selectedMapType) {
                    Text("Pre-defined").tag("pre-defined")
                    Text("Custom").tag("custom")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)
                
                VStack {
                    if selectedMapType == "custom" {
                        Text("To be implemented")
                            .foregroundColor(.secondary)
                    }
                    else {
                        Picker("Map", selection: $selectedDepartment) {
                            Text("Mathematics and Mechanics").tag("spbu-mm")
                            Text("Faculty of Physics").tag("spbu-pf")
                        }.pickerStyle(.automatic)
                        
                        
                    }
//                    else {
//                        EmptyView()
//                    }
                }
                .frame(width: 260, height: 35) // Increased height slightly for better spacing with MenuPickerStyle

                Button(action: {
                    // Update the selected department and dismiss
                    if (!isContinueButtonDisabled) {
                        showDepartmentSelection = false
                        showWelcomeScreen = false
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: 260, height: 30)
                .background(isContinueButtonDisabled ? Color.gray : Color.blue)
                .cornerRadius(8)
                .padding(.bottom,10)
            }
            .frame(width: 300, height: 220)
            .background(Color(.systemBackground).opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 10)
        }
        .onAppear {
            self.selectedMapType = "pre-defined"
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
        DepartmentSelectionScreen(showDepartmentSelection: .constant(true), showWelcomeScreen: .constant(true), selectedMapType: .constant(""), selectedDepartment: .constant(""))
    }
}
