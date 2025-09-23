//
//  ProfileView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 8/19/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var nickname = ""
    @State private var ageRange = "18-25"
    @State private var gender = "Prefer not to say"
    @State private var goal = "Better Sleep"

    let ageOptions = ["18-25", "26-35", "36-50", "50+"]
    let genderOptions = ["Male", "Female", "Non-binary", "Prefer not to say"]
    let goals = ["Better Sleep", "Lower Stress", "Improve Focus", "Overall Wellness"]

    var body: some View {
        Form {
            Section(header: Text("Your Info")) {
                TextField("Nickname", text: $nickname)

                Picker("Age Range", selection: $ageRange) {
                    ForEach(ageOptions, id: \.self) { Text($0) }
                }

                Picker("Gender", selection: $gender) {
                    ForEach(genderOptions, id: \.self) { Text($0) }
                }

                Picker("Wellness Goal", selection: $goal) {
                    ForEach(goals, id: \.self) { Text($0) }
                }
            }

            Section {
                Button("Save and Continue") {
                    let profile = UserProfile(id:UUID().uuidString, nickname: nickname, ageRange: ageRange, gender: gender, wellnessGoal: goal)
                    authVM.saveProfile(profile)
                }
            }
        }
        .navigationTitle("Your Profile")
    }
}

