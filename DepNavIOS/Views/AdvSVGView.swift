//
//  AdvSVGView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 29.06.2025.
//

import SVGView
import SwiftUI

struct AdvSVGView: View {
    let url: URL
    let svgNaturalSize: CGSize
    let containerHeightLimit: CGFloat = 250.0

    // Binding from the SVGMapView
    @Binding var markerCoordinate: CGPoint?

    // Permanent state
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    // Gesture state
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
                .onEnded { _ in
                    self.startOffset = self.offset
                }

            ZStack {
                CachedSVGView(contentsOf: url)
                    .aspectRatio(svgNaturalSize, contentMode: .fit)

                if let coord = markerCoordinate {
                    let markerPosition = calculateMarkerPosition(
                        svgCoordinate: coord,
                        svgNaturalSize: svgNaturalSize,
                        containerSize: geometry.size
                    )

                    PinMarkerView(color: .red)
                        .offset(y: -21) // half of the markers height
                        .scaleEffect(1.0 / self.scale)
                        .position(markerPosition)
                        .transition(.scale.animation(.spring()))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            // Transformation are being assigned to the whole ZStack (marker + map simultaneously)
            .scaleEffect(self.scale)
            .offset(self.offset)
            .clipped()
            .contentShape(Rectangle())
            .gesture(dragGesture.simultaneously(with: magnifyGesture))
            .onTapGesture(count: 2) {
                print("(ZoomableSVGView) Recognised gesture: Double tap")
                withAnimation(.spring()) {
                    if self.scale > 4.0 {
                        self.scale = 1.0
                        self.offset = .zero
                    } else {
                        self.scale *= 2.0
                        self.offset = CGSize(width: self.offset.width * 2.0, height: self.offset.height * 2.0)
                    }
                    self.startScale = self.scale
                    self.startOffset = self.offset
                }
            }
        }
    }

    private func clampOffset(_ offset: CGSize, for scale: CGFloat, in containerSize: CGSize) -> CGSize {
        if scale <= 1.0 {
            return .zero
        }

        let scaledContentSize = CGSize(
            width: containerSize.width * scale,
            height: containerSize.height * scale
        )

        let horizontalOverflow = (scaledContentSize.width - containerSize.width) / 2.0
        let verticalOverflow = (containerHeightLimit * scale - containerSize.height) / 2.0

        let newX = max(-horizontalOverflow, min(horizontalOverflow, offset.width))
        let newY = max(-verticalOverflow, min(verticalOverflow, offset.height))

        return CGSize(width: newX, height: newY)
    }

    private func calculateMarkerPosition(svgCoordinate: CGPoint, svgNaturalSize: CGSize, containerSize: CGSize) -> CGPoint {
        let svgAspectRatio = svgNaturalSize.width / svgNaturalSize.height
        let containerAspectRatio = containerSize.width / containerSize.height

        let finalContentSize: CGSize
        let contentOrigin: CGPoint

        if svgAspectRatio > containerAspectRatio {
            // svg is wider than container
            let height = containerSize.width / svgAspectRatio
            finalContentSize = CGSize(width: containerSize.width, height: height)
            contentOrigin = CGPoint(x: 0, y: (containerSize.height - height) / 2)
        } else {
            let width = containerSize.height * svgAspectRatio
            finalContentSize = CGSize(width: width, height: containerSize.height)
            contentOrigin = CGPoint(x: (containerSize.width - width) / 2, y: 0)
        }

        let scaleX = finalContentSize.width / svgNaturalSize.width
        let scaleY = finalContentSize.height / svgNaturalSize.height

        let x = (svgCoordinate.x * scaleX) + contentOrigin.x
        let y = (svgCoordinate.y * scaleY) + contentOrigin.y

        return CGPoint(x: x, y: y)
    }
}
