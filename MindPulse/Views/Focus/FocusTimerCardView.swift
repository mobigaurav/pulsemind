//
//  FocusTimerCardView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/16/25.
//

import SwiftUI

struct FocusTimerCardView: View {
    var body: some View {
        NavigationLink(destination: FocusTimerView()) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Focus Timer")
                        .font(.headline)
                    Text("Boost your concentration")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "timer")
                    .font(.largeTitle)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

