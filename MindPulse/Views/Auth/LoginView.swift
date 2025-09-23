//
//  LoginView.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 8/22/25.
//

import SwiftUI

struct RoundedTextField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
    }
}

struct RoundedSecureField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        SecureField(title, text: $text)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
    }
}


struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var appState: AppStateViewModel
    var body: some View {
        VStack(spacing: 24) {
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
            
            Text("Welcome Back")
                .font(.largeTitle.bold())
                .padding(.top)

            RoundedTextField(title: "Email", text: $email)
            RoundedSecureField(title: "Password", text: $password)

            Button("Login") {
                authVM.signIn(email: email, password: password)
            }
            .onReceive(authVM.$isAuthenticated) { isAuth in
                if isAuth {
                    appState.destination = .mainApp
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(radius: 3)

            Spacer()
        }
        .padding()
    }
}



#Preview {
    LoginView()
            .environmentObject(AuthViewModel())
            .environmentObject(AppStateViewModel())
}
