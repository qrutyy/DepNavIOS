import SwiftUI
import SVGView

struct SVGMapView: View {
    
    let floor: String
    let department: String

    var body: some View {
        if let url = Bundle.main.url(forResource: floor, withExtension: "svg", subdirectory: "Maps/\(department)") {
            
            ZoomableSVGView(
                            url: url,
                            svgNaturalSize: CGSize(width: 1200, height: 1200)
                        )
                        .onAppear {
                            print("SVGView: layout for file 'Maps/\(department)/\(floor)'")
                        }
            
        } else {
            VStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                Text("Map isn't found")
                    .font(.headline)
                Text("File '\(department)/\(floor).svg' doesn't exist.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .onAppear {
                print("SVGView: File '\(department)/\(floor).svg' wasn't found.")
            }
        }
    }
}
