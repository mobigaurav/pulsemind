//
//  OnboardingPageView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/18/25.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .padding()

            Text(page.title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .foregroundColor(.white)

            Text(page.subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingPageView(page: .init(title: "Title", subtitle: "Subtitle", imageName: "image"))
}

