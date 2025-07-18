//
//  MoodSummaryScrollView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/16/25.
//

import SwiftUI

struct MoodEntry: Identifiable {
    let id = UUID()
    let date: Date
    let mood: String
}

struct MoodSummaryScrollView: View {
    let moods: [MoodEntry]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(moods) { mood in
                    VStack {
                        Text(mood.mood)
                            .font(.largeTitle)
                        Text(formattedDate(mood.date))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}


