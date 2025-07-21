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
    @Binding var selectedMarker: String
    let coords: CGPoint

    var body: some View {
        iconForType(type)
            .font(.title)
            .frame(width: 45, height: 45, alignment: .center)
            .contentShape(Rectangle())
            .onTapGesture {
                print("updated selectedMarker to: \(title), \(coords), \(type)")
                selectedMarker = title
                let labRooms = (3241 ... 3251).map { String($0) }
                if labRooms.contains(title) {
                    print("playing doom easter egg")
                    SoundManagerViewModel.instance.playSound(sound: SoundOptions.doom)
                }
            }
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
            HStack(spacing: 0) {
                Image(systemName: "person.fill")
                Image(systemName: "arrow.up.and.down")
            }.font(.system(size: 20))
        case .WC_MAN:
            Image(systemName: "figure.stand")
                .foregroundColor(.cyan)
                .font(.system(size: 20))
        case .WC_WOMAN:
            Image(systemName: "figure.dress.line.vertical.figure")
                .foregroundColor(.pink)
                .font(.system(size: 20))
        case .WC:
            Image(systemName: "toilet")
                .foregroundColor(.gray)
                .font(.system(size: 20))
        case .OTHER:
            Image(systemName: "mappin.and.ellipse")
                .foregroundColor(.brown)
        }
    }
}
