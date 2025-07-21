//
//  DepSelectionScreenView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 29.06.2025.
//

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
                Text(LocalizedString("map_type_title", comment: "Select Map Type"))
                    .font(.headline)
                    .foregroundColor(.primary)

                Picker(LocalizedString("map_type_subtitle", comment: "Map Type"), selection: $selectedMapType) {
                    Text(LocalizedString("map_type_pre_defined", comment: "Pre-defined")).tag("pre-defined")
                    Text(LocalizedString("map_type_custom", comment: "Custom")).tag("custom")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)

                VStack {
                    if selectedMapType == "custom" {
                        Text(LocalizedString("generic_to_be_implemented", comment: "To be implemented"))
                            .foregroundColor(.secondary)
                    } else {
                        Picker(LocalizedString("generic_map_department_selection_title", comment: "Map"), selection: $selectedDepartment) {
                            Text(LocalizedString("department_name_mm", comment: "Mathematics and Mechanics")).tag("spbu-mm")
                            Text(LocalizedString("department_name_ph", comment: "Faculty of Phisics")).tag("spbu-pf")
                        }.pickerStyle(.automatic)
                    }
//                    else {
//                        EmptyView()
//                    }
                }
                .frame(width: 260, height: 35) // Increased height slightly for better spacing with MenuPickerStyle

                Button(action: {
                    // Update the selected department and dismiss
                    if !isContinueButtonDisabled {
                        showDepartmentSelection = false
                        showWelcomeScreen = false
                    }
                }) {
                    Text(LocalizedString("generic_continue_button", comment: "Generic continue button"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: 260, height: 35)
                .background(isContinueButtonDisabled ? Color.gray : Color.blue)
                .cornerRadius(8)
                .padding(.bottom, 5)
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
