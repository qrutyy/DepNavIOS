//
//  SearchResultRowView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 11.07.2025.
//

import SwiftUI

struct SearchResultRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    let type: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                if subtitle == "" {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    Text(stringFormatType(type))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private func stringFormatType(_ objType: String) -> String {
        switch objType {
        case "Room":
            return LocalizedString("marker_type_room")
        case "Entrance":
            return LocalizedString("marker_type_entrance")
        case "Stairs up", "Stairs down", "Stairs both":
            return LocalizedString("marker_type_stairs")
        case "Elevator":
            return LocalizedString("marker_type_elevator")
        case "WC", "WC man", "WC woman":
            return LocalizedString("marker_type_wc")
        default:
            return LocalizedString("marker_type_unknown")
        }
    }
}

#Preview {
    SearchResultRowView(icon: "door.french.open", title: "Test", subtitle: "", type: "Class")
}
