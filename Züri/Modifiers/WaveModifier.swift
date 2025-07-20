//
//  WaveModifier.swift
//  Züri
//
//  Created by Erik Schnell on 18.03.2025.
//

import SwiftUI

struct WaveEffect: ViewModifier {
    @State private var animationAmount: CGFloat = 0
    let isLoading: Bool
    let startDate = Date()
    
    func body(content: Content) -> some View {
        TimelineView(.animation) { context in
            content
                .distortionEffect(
                    ShaderLibrary.wave(.float(context.date.timeIntervalSince(startDate)), .float(animationAmount)),
                    maxSampleOffset: .init(width: 0, height: 50 * animationAmount)
                )
        }
        .onAppear {
            animationAmount = isLoading ? 1 : 0
        }
        .onChange(of: isLoading) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.1)) {
                animationAmount = newValue ? 1 : 0
            }
        }
    }
}

extension View {
    func waveEffect(isLoading: Bool) -> some View {
        self.modifier(WaveEffect(isLoading: isLoading))
    }
}
