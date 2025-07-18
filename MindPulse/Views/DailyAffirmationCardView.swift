//
//  DailyAffirmationCardView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/16/25.
//

import SwiftUI

struct DailyAffirmationCardView: View {
    private let affirmations = [
        "You are calm and in control.",
        "Today is a fresh start.",
        "You have the power to create change.",
        "Peace begins with a deep breath.",
        "You are strong, focused, and balanced.",
        "Your mind and body are in harmony.",
        "Every step you take is progress."
    ]
    
    // Simple way to rotate the affirmation once per app launch
    private var selectedAffirmation: String {
        affirmations.randomElement() ?? "Breathe and begin again."
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Daily Affirmation")
                .font(.headline)
                .foregroundColor(.white)

            Text("“\(selectedAffirmation)”")
                .font(.body)
                .italic()
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.4), radius: 6, x: 0, y: 4)
        .padding(.horizontal)
    }
}

