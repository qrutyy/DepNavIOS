//
//  CloseButtonView.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 13.07.2025.
//

import SwiftUI

struct CloseButtonView: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) { // Вызываем переданное действие
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary) // .secondary - хороший адаптивный серый
        }
        .frame(width: 24, height: 24)
        .background(Color(.systemGray6)) // .systemGray6 - еще один хороший вариант для фона
        .clipShape(Circle())
    }
}

#Preview {}
