//
//  QuickActionsView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/16/25.
//

import SwiftUI

struct QuickActionsView: View {
    var actions: [QuickAction] = QuickAction.defaultActions

    var body: some View {
        VStack(alignment: .leading) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(actions) { action in
                        NavigationLink(destination: action.destinationView) {
                            VStack(spacing: 8) {
                                Image(systemName: action.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)

                                Text(action.title)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(width: 100, height: 100)
                            .background(action.color)
                            .cornerRadius(14)
                            .shadow(radius: 4)
                        }
                    }
                }
            }
        }
    }
}


