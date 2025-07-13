//
//  FavoriteItemView.swift
//  DepNavIOS
//
//  Created by Michael Gavrilenko on 11.07.2025.
//

import SwiftUI

struct FavoriteItemView: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(iconColor)
            }

            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FavoriteItemView(icon: "star", title: "Starred", subtitle: "123 items", iconColor: .yellow)
}
