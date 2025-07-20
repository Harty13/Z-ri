//
//  VerticalMapSlider.swift
//  Züri
//
//  Created by Erik Schnell on 20.03.2025.
//

import SwiftUI

struct VerticalMapSlider: View {
    @Binding var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 30)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
                    .frame(width: 30, height: CGFloat(value) * geometry.size.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    let location = geometry.size.height - gesture.location.y
                    let newValue = max(0, min(1, location / geometry.size.height))
                    value = newValue
                }
            )
        }
    }
}
