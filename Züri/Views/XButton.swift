//
//  XButton.swift
//  Züri
//
//  Created by Erik Schnell on 19.03.2025.
//

import SwiftUI

import SwiftUI

struct XButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action, label: {
            Button(action: action, label: {
                    Circle()
                #if os(iOS)
                    .fill(Color(.secondarySystemFill))
                #endif
                    .frame(width: 30, height: 30)
                    .overlay(
                        Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.secondary)
                        )
                })
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(Text("Close"))
                .frame(width: 44, height: 44)
        })
    }
}
