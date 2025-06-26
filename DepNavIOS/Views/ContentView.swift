import SwiftUI

struct ContentView: View {
    @State private var selectedFloor: String = "floor1"
    @State private var selectedDepartment: String = "spbu-mm"
    @State private var showWelcomeScreen = true

    var body: some View {
        VStack(spacing: 0) {
            // Welcome Screen
            Button(action: {
                self.showWelcomeScreen = true
            }) {
                Label("Show Welcome screen", systemImage: "sparkles")
                    .padding(.top, 16)
            }
            .sheet(isPresented: $showWelcomeScreen) {
                WelcomeScreen(
                    showWelcomeScreen: $showWelcomeScreen,
                    selectedDepartment: $selectedDepartment
                )
            }

            // Header
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("DEPNAV BETA")
                    .font(.headline)
            }
            .padding(.bottom, 8)

            // Floor picker
            Picker("Select Floor", selection: $selectedFloor) {
                Text("Floor 1").tag("floor1")
                Text("Floor 2").tag("floor2")
                Text("Floor 3").tag("floor3")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)


            SVGMapView(floor: selectedFloor, department: selectedDepartment)
                            .frame(height: 500)
                            .border(Color.green, width: 2)
                            .padding()
        }
    }
}

#Preview {
    ContentView()
}


