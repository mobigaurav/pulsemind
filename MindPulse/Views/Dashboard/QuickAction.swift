//
//  QuickAction.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/16/25.
//

import SwiftUI

struct QuickAction: Identifiable {
    
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let destinationView: AnyView
 
    
    static var defaultActions: [QuickAction] {
        [
            QuickAction(title: "Journal", icon: "book.closed", color: .indigo, destinationView: AnyView(JournalingView())),
            QuickAction(title: "Breath", icon: "wind", color: .teal, destinationView: AnyView(BreathingView())),
            QuickAction(title: "Timer", icon: "timer", color: .purple, destinationView: AnyView(FocusTimerView()))
        ]
    }
}

