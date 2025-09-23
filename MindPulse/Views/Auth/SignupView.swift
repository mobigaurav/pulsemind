//
//  SignupView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 8/22/25.
//

import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var nickname = ""
    @State private var selectedGoal = "Better Sleep"
    @State private var ageRange = ""
    @State private var gender = ""
    @State private var showProfileCompletion = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appState: AppStateViewModel
    
    let goals = ["Better Sleep", "Lower Stress", "Improve Focus", "Overall Wellness"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Back Button
                HStack {
                    Button(action: {
                        appState.destination = .welcome
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                        Text("Back")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }

                // Title
                Text("Create Account")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 16)

                // Input Fields
                RoundedTextField(title: "Email", text: $email)
                RoundedSecureField(title: "Password", text: $password)
                RoundedSecureField(title: "Confirm Password", text: $confirmPassword)

                // Optional Goal
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Wellness Goal")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Picker("Goal", selection: $selectedGoal) {
                        ForEach(goals, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }

                Button(action: {
                    showProfileCompletion = true
                }) {
                    Text("Save and Continue")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $showProfileCompletion) {
                ProfileCompletionView(
                    userProfile: UserProfile(
                        id: UUID().uuidString,
                        nickname: nickname,
                        ageRange: ageRange,
                        gender: gender,
                        wellnessGoal: selectedGoal
                    )
                )
                .environmentObject(authVM)
            }
        }
    }
}

