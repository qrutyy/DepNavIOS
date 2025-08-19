//
//  DepSelectionScreenView.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 29.06.2025.
//

import SwiftUI


struct DepartmentSelectionScreen: View {
    @Binding var showDepartmentSelection: Bool
    @Binding var showWelcomeScreen: Bool
    @Binding var selectedMapType: String
    @Binding var selectedDepartment: String
    
    @Binding var authorisationFailed: Bool

    @StateObject private var session = SessionStore()
    @StateObject private var vm: DepSelectionViewModel

    init(showDepartmentSelection: Binding<Bool>, showWelcomeScreen: Binding<Bool>, selectedMapType: Binding<String>, selectedDepartment: Binding<String>) {
        _showDepartmentSelection = showDepartmentSelection
        _showWelcomeScreen = showWelcomeScreen
        _selectedMapType = selectedMapType
        _selectedDepartment = selectedDepartment
        _vm = StateObject(wrappedValue: DepSelectionViewModel(session: SessionStore()))
        _authorisationFailed = .constant(false)
    }

    private var isContinueButtonDisabled: Bool {
        selectedMapType == "custom" && authorisationFailed
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
                        TextField(LocalizedString("map_code_placeholder", comment: "Textfield placeholder for map code"), text: $vm.mapCodeInput)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.search)
                        
                        if authorisationFailed {
                            Text(LocalizedString("authorisation_fail", comment: "Failed to authorise"))
                        }
                    } else {
                        Picker(LocalizedString("generic_map_department_selection_title", comment: "Map"), selection: $selectedDepartment) {
                            Text(LocalizedString("department_name_mm", comment: "Mathematics and Mechanics")).tag("spbu-mm")
                            Text(LocalizedString("department_name_ph", comment: "Faculty of Phisics")).tag("spbu-pf")
                        }.pickerStyle(.automatic)
                    }
                }
                .frame(width: 260)

                Button(action: {
                    Task {
                        if selectedMapType == "custom" {
                            await vm.authorizeAndStore(mapCode: vm.mapCodeInput)
                            if (vm.error != nil && vm.error!.isEmpty == false) {
                                authorisationFailed = true
                                vm.mapCodeInput = ""
                                print("Failed to authorize: \(vm.error!)")
                                vm.error = nil
                            } else {
                                if !isContinueButtonDisabled {
                                    showDepartmentSelection = false
                                    showWelcomeScreen = false
                                }
                            }
                        } else {
                            if !isContinueButtonDisabled {
                                showDepartmentSelection = false
                                showWelcomeScreen = false
                            }
                        }
                        
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
            .frame(width: 300, height: 260)
            .background(Color(.systemBackground).opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 10)
        }
        .onAppear { selectedMapType = "pre-defined" }
    }
}

// BlurView to create the blurred background
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context _: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
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
