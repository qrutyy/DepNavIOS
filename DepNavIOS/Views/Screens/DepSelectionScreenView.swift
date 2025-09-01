//
//  DepSelectionScreenView.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 29.06.2025.
//

import SwiftUI


struct DepartmentSelectionScreen: View {
    @Binding var showDepartmentSelection: Bool
    @ObservedObject var mapViewModel: MapViewModel
    @Binding var session: SessionStore
    
    @State var authorisationFailed: Bool = false
    @StateObject private var vm: DepSelectionViewModel
    
    @State private var isLoading: Bool = false

    init(showDepartmentSelection: Binding<Bool>, mapViewModel: MapViewModel, session: Binding<SessionStore>) {
        _showDepartmentSelection = showDepartmentSelection
        _mapViewModel = ObservedObject(initialValue: mapViewModel)
        _vm = StateObject(wrappedValue: DepSelectionViewModel(session: session.wrappedValue))
        _session = session
    }

    private var isContinueButtonDisabled: Bool {
        mapViewModel.selectedMapType == "custom" && authorisationFailed
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

                Picker(LocalizedString("map_type_subtitle", comment: "Map Type"), selection: $mapViewModel.selectedMapType) {
                    Text(LocalizedString("map_type_pre_defined", comment: "Pre-defined")).tag("pre-defined")
                    Text(LocalizedString("map_type_custom", comment: "Custom")).tag("custom")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 20)

                VStack {
                    if mapViewModel.selectedMapType == "custom" {
                        TextField(LocalizedString("map_code_placeholder", comment: "Textfield placeholder for map code"), text: $vm.mapCodeInput)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.search)
                        // when re entering - make blue
                        
                        if authorisationFailed {
                            Text(LocalizedString("authorisation_fail", comment: "Failed to authorise")).foregroundStyle(Color(.red)).font(.caption)
                            if let error = vm.error {
                                let start = error.index(error.startIndex, offsetBy: 10)
                                let end = error.index(error.endIndex, offsetBy: -2)
                                let substring = error[start..<end]
                                Text(String(substring))
                                    .foregroundStyle(Color.red)
                                    .font(.caption)
                            }
                    
                        }
                    } else {
                        Picker(LocalizedString("generic_map_department_selection_title", comment: "Map"), selection: $mapViewModel.selectedDepartment) {
                            Text(LocalizedString("department_name_mm", comment: "Mathematics and Mechanics")).tag("spbu-mm")
                            Text(LocalizedString("department_name_ph", comment: "Faculty of Phisics")).tag("spbu-pf")
                        }.pickerStyle(.automatic)
                    }
                }
                .frame(width: 260)

                Button(action: {
                    Task {
                        if mapViewModel.selectedMapType == "custom" {
                            await vm.authorizeAndStore(mapCode: vm.mapCodeInput)
                            if (vm.error != nil && vm.error!.isEmpty == false) {
                                authorisationFailed = true
                                vm.mapCodeInput = ""
                                print("Failed to authorize: \(vm.error!)")
                            } else {
                                if !isContinueButtonDisabled {
                                    isLoading = true
                                    await mapViewModel.loadCustomMapFromServer(mapCode: vm.mapCodeInput)
                                    isLoading = false
                                    showDepartmentSelection = false
                                }
                            }
                        } else {
                            if !isContinueButtonDisabled {
                                showDepartmentSelection = false
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
                .disabled(isLoading) // prevent spam taps
            }
            .frame(width: 300, height: 260)
            .background(Color(.systemBackground).opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 10)
        }
        .onAppear {
            mapViewModel.selectedMapType = "pre-defined"
            mapViewModel.setSessionStore($session.wrappedValue)
        }
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
        DepartmentSelectionScreen(showDepartmentSelection: .constant(true), mapViewModel: MapViewModel(), session: .constant(SessionStore()))
    }
}
