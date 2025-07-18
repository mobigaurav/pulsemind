//
//  OnboardingView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/18/25.
//
import SwiftUI

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
}

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(title: "Welcome to MindPulse", subtitle: "Track heart rate, HRV, and stress in real-time", imageName: "heart_icon"),
        OnboardingPage(title: "Sync with Apple Watch", subtitle: "Seamless integration for deeper insights", imageName: "watch_icon"),
        OnboardingPage(title: "Breathe & Reflect", subtitle: "Use guided breathing and mood check-ins", imageName: "breathe_icon")
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("AccentColor"), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .animation(.easeInOut, value: currentPage)

                Button(action: {
                    hasSeenOnboarding = true
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Skip")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                }
            }
        }
    }
}


