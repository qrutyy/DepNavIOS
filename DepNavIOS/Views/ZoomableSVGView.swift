import SwiftUI
import SVGView

struct ZoomableSVGView: View {
    
    let url: URL
    let svgNaturalSize: CGSize
    let containerHeightLimit: CGFloat = 200.0
    
    // Permanent state
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    // Gesture init state
    @State private var startOffset: CGSize = .zero
    @State private var startScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            
            let magnifyGesture = MagnificationGesture()
                .onChanged { value in
                    self.scale = max(1.0, startScale * value)
                }
                .onEnded { value in
                    self.scale = max(1.0, startScale * value)
                    self.startScale = self.scale
                    
                    self.offset = clampOffset(offset, for: self.scale, in: geometry.size)
                    self.startOffset = self.offset
                }
            
            let dragGesture = DragGesture()
                .onChanged { value in
                    let newOffset = CGSize(
                        width: startOffset.width + value.translation.width,
                        height: startOffset.height + value.translation.height
                    )
                    
                    self.offset = clampOffset(newOffset, for: self.scale, in: geometry.size)
                }
                .onEnded { value in
                    self.startOffset = self.offset
                }

            ZStack {
                SVGView(contentsOf: url)
                    .aspectRatio(svgNaturalSize, contentMode: .fit)
                    .scaleEffect(self.scale)
                    .offset(self.offset)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
            .contentShape(Rectangle())
            .gesture(dragGesture.simultaneously(with: magnifyGesture))
            .onTapGesture(count: 2) {
                print("(ZoomableSVGView) Recognised gesture: Double tap")
                withAnimation(.spring()) {
                    if self.scale > 5.0 {
                        // move to initial scale
                        self.scale = 1.0
                        self.offset = .zero
                    } else {
                        // scale up
                        self.scale *= 2.0
                        self.offset = CGSize(width: self.offset.width * 2.0, height: self.offset.height * 2.0)
                    }
                    // reset to initial values
                    self.startScale = self.scale
                    self.startOffset = self.offset
                }
            }
        }
    }
    
    // Clamps the SVG placement while movement occurs
    private func clampOffset(_ offset: CGSize, for scale: CGFloat, in containerSize: CGSize) -> CGSize {
        if scale <= 1.0 { // blocking the movement when scale <= 1
            return .zero
        }
        
        let scaledContentSize = CGSize(
            width: containerSize.width * scale,
            height: containerSize.height * scale
        )
        print("\(containerSize.height)")

        let horizontalOverflow = (scaledContentSize.width - containerSize.width) / 2.0
        let verticalOverflow = (containerHeightLimit * scale - containerSize.height) / 2.0
        
        let newX = max(-horizontalOverflow, min(horizontalOverflow, offset.width))
        let newY = max(-verticalOverflow, min(verticalOverflow, offset.height))
        
        return CGSize(width: newX, height: newY)
    }
}
