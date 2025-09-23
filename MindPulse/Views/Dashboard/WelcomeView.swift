//
//  WelcomeView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 8/19/25.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppStateViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("AccentColor"), .white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()
                
                Image("pulsemind")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .shadow(radius: 10)
                
                Text("Welcome to PulseMind")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.primary)
                
                Text("Your personal wellness companion for stress, heart rate, and mindfulness.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        appState.isGuest = true
                        appState.evaluateLaunchDestination()
                    }) {
                        HStack {
                            Image(systemName: "person.fill.questionmark")
                            Text("Continue as Guest")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                    }

                    Button(action: {
                        //authViewModel.handleAppleSignIn()
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                            Text("Continue with Apple")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    HStack {
                        Button(action: {
                            appState.destination = .login
                        }) {
                            Text("Log In")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor.opacity(0.2))
                                .foregroundColor(.accentColor)
                                .cornerRadius(12)
                        }

                        Button(action: {
                            appState.destination = .signup
                        }) {
                            Text("Sign Up")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
    }
}



#Preview {
    WelcomeView()
}
