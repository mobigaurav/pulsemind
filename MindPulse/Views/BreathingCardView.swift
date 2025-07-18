//
//  BreathingCardView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/16/25.
//

import SwiftUI

struct BreathingCardView: View {
    var body: some View {
        HStack {
            Image(systemName: "wind")
                .font(.largeTitle)
                .padding()
            VStack(alignment: .leading) {
                Text("Breathing Exercise")
                    .font(.headline)
                Text("Calm your mind in 60 seconds")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
}

