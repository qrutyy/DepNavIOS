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
    let currentDep: String
    let floor: String

    private var formattedDep: String {
        if currentDep == "spbu-pf" {
            return LocalizedString("settings_department_pf", comment: "")
        } else {
            return LocalizedString("settings_department_mm", comment: "")
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                if subtitle == "" || subtitle == title {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    Text("\(stringFormatType(type)), \(floor) " + LocalizedString("map_vm_floor") + ", \(formattedDep)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    Text("\(subtitle), \(floor) " + LocalizedString("map_vm_floor") + ", \(formattedDep)")
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
}

// #Preview {
//    SearchResudltRowView(icon: "door.french.open", title: "Test", subtitle: "", type: "Class")
// }
