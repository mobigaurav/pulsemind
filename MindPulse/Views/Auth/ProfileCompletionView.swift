//
//  ProfileCompletionView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 8/22/25.
//

import SwiftUI

struct ProfileCompletionView: View {
    @State var userProfile: UserProfile
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appState: AppStateViewModel

    let ageRanges = ["18-24", "25-34", "35-44", "45+"]
    let genders = ["Male", "Female", "Non-binary", "Prefer not to say"]

    var body: some View {
        VStack(spacing: 24) {
            Text("Complete Your Profile")
                .font(.title)
                .bold()

            RoundedTextField(title: "Nickname", text: $userProfile.nickname)

            VStack(alignment: .leading, spacing: 8) {
                Text("Age Range")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Picker("Select Age Range", selection: $userProfile.ageRange) {
                    ForEach(ageRanges, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Gender")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Picker("Select Gender", selection: $userProfile.gender) {
                    ForEach(genders, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }

            Button(action: {
                authVM.saveProfile(userProfile)
                authVM.isAuthenticated = true
                authVM.isGuest = false
                appState.destination = .mainApp
            }) {
                Text("Finish")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }
}


