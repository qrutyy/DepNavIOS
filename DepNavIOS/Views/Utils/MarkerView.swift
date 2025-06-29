//
//  MarkerView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 29.06.2025.
//

import SwiftUI

struct ClassicPinShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let tipPoint = CGPoint(x: rect.midX, y: rect.maxY)
        let circleCenter = CGPoint(x: rect.midX, y: rect.height * 0.35)
        let circleRadius = rect.width * 0.4

        let angle: CGFloat = 30 * .pi / 180
        let leftPoint = CGPoint(
            x: circleCenter.x - circleRadius * cos(angle),
            y: circleCenter.y + circleRadius * sin(angle)
        )

        path.move(to: leftPoint)

        path.addArc(
            center: circleCenter,
            radius: circleRadius,
            startAngle: Angle(radians: .pi - angle),
            endAngle: Angle(radians: angle),
            clockwise: false
        )

        path.addLine(to: tipPoint)
        path.addLine(to: leftPoint)

        return path
    }
}

struct PinMarkerView: View {
    var color: Color = .red

    var body: some View {
        ZStack {
            // shade
            Ellipse()
                .fill(Color.black.opacity(0.2))
                .frame(width: 20, height: 8)
                .blur(radius: 3)
                .offset(y: 25)

            ZStack {
                ClassicPinShape()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.lighter(), color]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        ClassicPinShape()
                            .stroke(Color.black.opacity(0.15), lineWidth: 0.5)
                    )
                // white circle inside
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .offset(y: -8)
                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            }
            .frame(width: 32, height: 42)
        }
    }
}

extension Color {
    func darker(by percentage: Double = 0.2) -> Color {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return self
        }
        return Color(UIColor(
            red: max(red - percentage, 0),
            green: max(green - percentage, 0),
            blue: max(blue - percentage, 0),
            alpha: alpha
        ))
    }

    func lighter(by percentage: Double = 0.2) -> Color {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return self
        }
        return Color(UIColor(
            red: min(red + percentage, 1.0),
            green: min(green + percentage, 1.0),
            blue: min(blue + percentage, 1.0),
            alpha: alpha
        ))
    }
}

// Preview
struct PinMarkerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            HStack(spacing: 30) {
                PinMarkerView(color: .red)
                PinMarkerView(color: .blue)
                PinMarkerView(color: .green)
            }

            HStack(spacing: 30) {
                PinMarkerView(color: .orange)
                PinMarkerView(color: .purple)
                PinMarkerView(color: .pink)
            }
        }
        .padding(40)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .previewLayout(.sizeThatFits)
    }
}
