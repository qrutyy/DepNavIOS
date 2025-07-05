//
//  GenericMarkerView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 30.06.2025.
//

import SwiftUI

struct GenericMarkerView: View {
    let type: MarkerType
    let title: String

    var body: some View {
        iconForType(type)
            .font(.title)
            .frame(width: 40, alignment: .center)
    }

    @ViewBuilder
    private func iconForType(_ type: MarkerType) -> some View {
        switch type {
        case .ENTRANCE:
            Image(systemName: "door.left.hand.open")
                .foregroundColor(.green)
        case .ROOM:
            Text(title).font(.caption)
        case .STAIRS_UP:
            Image(systemName: "arrow.up.square")
                .foregroundColor(.orange)
        case .STAIRS_DOWN:
            Image(systemName: "arrow.down.square")
                .foregroundColor(.orange)
        case .STAIRS_BOTH:
            Image(systemName: "arrow.up.and.down.square")
                .foregroundColor(.orange)
        case .ELEVATOR:
            Image(systemName: "elevator")
                .foregroundColor(.purple)
        case .WC_MAN:
            Image(systemName: "figure.stand")
                .foregroundColor(.cyan)
        case .WC_WOMAN:
            Image(systemName: "figure.dress.line.vertical.figure")
                .foregroundColor(.pink)
        case .WC:
            Image(systemName: "toilet")
                .foregroundColor(.gray)
        case .OTHER:
            Image(systemName: "mappin.and.ellipse")
                .foregroundColor(.brown)
        }
    }
}
