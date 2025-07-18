//
//  BreathingCircleView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import SwiftUI

struct BreathingCircleView: View {
    @Binding var isAnimating: Bool
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(Color.green.opacity(0.3))
            .frame(width: 200, height: 200)
            .scaleEffect(scale)
            .animation(
                .easeInOut(duration: 4)
                .repeatForever(autoreverses: true),
                value: scale
            )
            .onChange(of: isAnimating) { running in
                if running {
                    scale = 1.4
                } else {
                    scale = 1.0
                }
            }
    }
}

