//
//  SearchResultRowView.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 11.07.2025.
//

import SwiftUI

struct SearchResultRowView: View {
    let mapObject: InternalMarkerModel
    let currentDep: String

    private var iconName: String {
        getMapObjectIconByType(objectTypeName: mapObject.type.displayName)
    }

    private var formattedDep: String {
        if currentDep == "spbu-pf" {
            LocalizedString("settings_department_pf", comment: "")
        } else {
            LocalizedString("settings_department_mm", comment: "")
        }
    }

    @ViewBuilder
    private var detailsView: some View {
        let formattedLocation = (mapObject.location == nil || mapObject.location == "") ? "" : "\(mapObject.location ?? ""), "
        if mapObject.description == "" || mapObject.description == mapObject.title {
            Text(mapObject.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            Text("\(stringFormatType(mapObject.type.displayName)), \(formattedLocation)\(mapObject.floor) " + LocalizedString("map_vm_floor") + ", \(formattedDep)")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        } else {
            Text(mapObject.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            Text("\(mapObject.description ?? "unknown (bug)"), \(formattedLocation)\(String(mapObject.floor)) " + LocalizedString("map_vm_floor") + ", \(formattedDep)")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                detailsView
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
