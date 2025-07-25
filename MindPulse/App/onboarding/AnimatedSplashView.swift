//
//  AnimatedSplashView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/18/25.
//

import SwiftUI
struct AnimatedSplashView: View {
    @State private var isActive = false
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @StateObject private var viewModel = HealthKitViewModel()
    
    var body: some View {
        if isActive {
            // Navigate to onboarding or dashboard
            if hasSeenOnboarding {
                MainTabView()
                } else {
                OnboardingView()
                }
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color("AccentColor"), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                VStack {
                    Image("pulsemind")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .scaleEffect(1.2)
                        .animation(.easeIn(duration: 0.8), value: isActive)

                    Text("PulseMind")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .opacity(0.8)
                        .padding(.top, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                //.background(Color("SplashBackground")) // Optional custom color
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

