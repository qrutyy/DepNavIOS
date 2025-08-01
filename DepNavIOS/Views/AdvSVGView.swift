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
    @ObservedObject var mapViewModel: MapViewModel

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var startOffset: CGSize = .zero
    @State private var startScale: CGFloat = 2.0

    @State private var latestGestureScale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var liveScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            mapContentView(for: geometry)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .scaleEffect(gestureScale * scale)
                .offset(offset)
                .clipped()
                .contentShape(Rectangle())
                .gesture(combinedGesture(for: geometry)) // Gestures are now combined in a helper
                .onTapGesture(count: 2) {
                    handleDoubleTap(in: geometry.size)
                }
                .onChange(of: mapViewModel.markerCoordinate) { newCoord in
                    guard let coord = newCoord else { return }
                    centerOnCoordinate(coord, in: geometry.size)
                }
                .onChange(of: mapViewModel.mapControl.isCentered) { newValue in
                    if newValue {
                        withAnimation(.spring()) {
                            offset = .zero
                            startOffset = .zero
                        }
                        mapViewModel.mapControl.isCentered = false
                    }
                }
                .onChange(of: mapViewModel.mapControl.isZoomedOut) { newValue in
                    if newValue {
                        withAnimation(.spring()) {
                            let newOffset = CGSize(
                                width: offset.width / scale,
                                height: offset.height / scale
                            )
                            offset = newOffset
                            startOffset = newOffset
                            scale = 1.0
                            startScale = 1.0
                        }
                        mapViewModel.mapControl.isZoomedOut = false
                    }
                }
        }
    }

    // MARK: - View Builders & Helpers

    /// Creates the main map content including the SVG and all markers.
    @ViewBuilder
    private func mapContentView(for geometry: GeometryProxy) -> some View {
        if let description = mapViewModel.currentMapDescription {
            let svgNaturalSize = CGSize(width: mapViewModel.currentMapDescription!.floorWidth, height: mapViewModel.currentMapDescription!.floorHeight)

            ZStack {
                // 1. The base SVG map
                CachedSVGView(contentsOf: url)
                    .aspectRatio(svgNaturalSize, contentMode: .fit)

                // 2. The tappable markers for the current floor
                if let currentFloorData = mapViewModel.currentMapDescription!.floors.first(where: { $0.floor == mapViewModel.selectedFloor }) {
                    ForEach(currentFloorData.markers, id: \.self) { marker in
                        let markerPosition = calculateMarkerPosition(
                            svgCoordinate: marker.coordinate,
                            svgNaturalSize: svgNaturalSize,
                            containerSize: geometry.size
                        )

                        // Note: Simplified the marker view for this example
                        let displayTitle = marker.ru.title ?? marker.en.title ?? ""
                        GenericMarkerView(type: marker.type, title: displayTitle, mapViewModel: mapViewModel, coords: marker.coordinate)
                            .offset(y: -21)
                            .scaleEffect(1.0 / 7.0)
                            .position(markerPosition)
                            
                    }
                }

                // 3. The pin for a selected search result
                if let coord = mapViewModel.markerCoordinate {
                    let markerPosition = calculateMarkerPosition(
                        svgCoordinate: coord,
                        svgNaturalSize: svgNaturalSize,
                        containerSize: geometry.size
                    )
                    PinMarkerView(color: .red)
                        .offset(y: -21)
                        .scaleEffect(1.0 / scale) // Pin should also scale down
                        .position(markerPosition) // Simplified this call for clarity
                        .transition(.move(edge: .top).combined(with: .opacity).animation(.spring()))
                }
            }
            .id(mapViewModel.selectedDepartment)

        }
    }

    // MARK: - Gestures

    private func combinedGesture(for geometry: GeometryProxy) -> some Gesture {
        let dragGesture = DragGesture()
            .onChanged { value in
                let newOffset = CGSize(
                    width: startOffset.width + value.translation.width,
                    height: startOffset.height + value.translation.height
                )
                offset = clampOffset(newOffset, for: scale, in: geometry.size)
            }

            .onEnded { _ in
                startOffset = offset
            }

        let magnifyGesture = MagnificationGesture()
            .updating($gestureScale) { value, state, _ in
                state = value
            }
            .onEnded { value in
                // Исправляем логику: используем latestGestureScale вместо прямого умножения
                let newScale = max(1.0, scale * value)
                scale = newScale
                startScale = newScale
                startOffset = offset
            }

        return dragGesture.simultaneously(with: magnifyGesture)
    }

    // MARK: - Helper Functions

    private func handleDoubleTap(in size: CGSize) {
        withAnimation(.spring()) {
            if scale > 4.0 {
                scale = 1.0
                offset = .zero
            } else {
                let newScale = scale * 2.0
                // This offset logic might need refinement to zoom into the tap location
                let newOffset = CGSize(width: offset.width * 2.0, height: offset.height * 2.0)
                scale = newScale
                offset = clampOffset(newOffset, for: newScale, in: size)
            }
            startScale = scale
            startOffset = offset
        }
    }

    private func centerOnCoordinate(_ coordinate: CGPoint, in containerSize: CGSize) {
        let svgNaturalSize = CGSize(width: mapViewModel.currentMapDescription!.floorWidth, height: mapViewModel.currentMapDescription!.floorHeight)

        let targetScale: CGFloat = 3.0

        let markerPosition = calculateMarkerPosition(
            svgCoordinate: coordinate,
            svgNaturalSize: svgNaturalSize,
            containerSize: containerSize
        )

        // Calculate the offset needed to move the marker's scaled position to the center of the screen
        let targetOffsetX = ((containerSize.width / 2) - markerPosition.x) * targetScale
        let targetOffsetY = ((containerSize.height / 2) - markerPosition.y) * targetScale
        var targetOffset = CGSize(width: targetOffsetX, height: targetOffsetY)

        // Make sure the calculated offset is within the allowed bounds
        targetOffset = clampOffset(targetOffset, for: targetScale, in: containerSize)

        withAnimation(.spring(response: 1, dampingFraction: 0.8)) {
            scale = targetScale
            offset = targetOffset

            startScale = scale
            startOffset = offset
        }
    }

    private func movePinMarkerUpper(_ position: CGPoint) -> CGPoint {
        // either way it also can be moved backwards in terms of layers
        // (mb this one will affect as better UX)
        CGPoint(x: position.x, y: position.y - 4)
    }

    private func clampOffset(_ offset: CGSize, for scale: CGFloat, in containerSize: CGSize) -> CGSize {
        if scale <= 1.0 {
            return .zero
        }

        let scaledContentSize = CGSize(
            width: containerSize.width * scale,
            height: containerSize.height * scale
        )

        let horizontalOverflow = (scaledContentSize.width - containerSize.width)
        let verticalOverflow = (scaledContentSize.height - containerSize.height) / 5.0

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
        let y = (svgCoordinate.y * scaleY) + contentOrigin.y + 3.0

        return CGPoint(x: x, y: y)
    }
}
