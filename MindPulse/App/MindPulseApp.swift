//
//  MindPulseApp.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

@main
struct MindPulseApp: App {
    @StateObject private var viewModel = HealthKitViewModel()
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @StateObject var authViewModel = AuthViewModel()
    
    init() {
            WatchSessionManager.shared.activate()
            configureAmplify()
        }
    
    func configureAmplify() {
        do {
               try Amplify.add(plugin: AWSCognitoAuthPlugin())
               try Amplify.configure()
               print("Amplify configured")
           } catch {
               print("Failed to configure Amplify: \(error)")
           }
    }
    
    var body: some Scene {
        WindowGroup {
            AnimatedSplashView()
                .environmentObject(authViewModel)
        }
    }
}


