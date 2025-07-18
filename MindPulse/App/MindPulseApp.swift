//
//  MindPulseApp.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import SwiftUI

@main
struct MindPulseApp: App {
    @StateObject private var viewModel = HealthKitViewModel()
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    init() {
            WatchSessionManager.shared.activate()
        }
    
    var body: some Scene {
        WindowGroup {
            AnimatedSplashView()
        }
    }
}


