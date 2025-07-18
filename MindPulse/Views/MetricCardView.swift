//
//  MetricCardView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import SwiftUI

struct MetricCardView: View {
    let title: String
    let value: Double?
    let unit: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            HStack {
                if let value = value {
                    Text(String(format: "%.1f", value))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(color)
                    Text(unit)
                        .font(.title3)
                        .foregroundColor(.gray)
                } else {
                    Text("—")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

