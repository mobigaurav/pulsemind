//
//  AuthViewModel.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 8/19/25.
//

import Foundation
import Combine
import SwiftUI
import Amplify
import AuthenticationServices

class AuthViewModel: ObservableObject {
    
    // MARK: - Published States
    @Published var isAuthenticated: Bool = false
    @Published var isGuest: Bool = false
    @Published var userProfile: UserProfile?
    @Published var authError: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Keys
    private let userProfileKey = "userProfile"

    init() {
        loadProfile()
        //checkAuthSession()
    }

    // MARK: - Guest Mode
    func continueAsGuest() {
        isGuest = true
        isAuthenticated = false
        print("👤 Continuing as guest")
    }

    // MARK: - Save and Load Profile
    func saveProfile(_ profile: UserProfile) {
        userProfile = profile
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: userProfileKey)
        }
    }

    func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: userProfileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
        }
    }

    func clearProfile() {
        UserDefaults.standard.removeObject(forKey: userProfileKey)
        userProfile = nil
    }

    // MARK: - AWS Cognito Authentication
    
//    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
//        let userAttributes = [AuthUserAttribute(.email, value: email)]
//
//        Amplify.Auth.signUp(username: email, password: password, options: .init(userAttributes: userAttributes)) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    print("✅ Sign up successful")
//                    completion(true)
//                case .failure(let error):
//                    self.authError = error.errorDescription
//                    print("❌ Sign up failed: \(error)")
//                    completion(false)
//                }
//            }
//        }
//    }

//    func confirmSignUp(email: String, code: String, completion: @escaping (Bool) -> Void) {
//        Amplify.Auth.confirmSignUp(for: email, confirmationCode: code) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let result):
//                    print("✅ Confirm sign up: \(result.isSignupComplete)")
//                    completion(result.isSignupComplete)
//                case .failure(let error):
//                    self.authError = error.errorDescription
//                    print("❌ Confirm sign up failed: \(error)")
//                    completion(false)
//                }
//            }
//        }
//    }

    func signIn(email: String, password: String) {
            Amplify.Publisher.create {
                try await Amplify.Auth.signIn(username: email, password: password)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(authError) = completion {
                    self.authError = authError.localizedDescription
                    print("❌ Sign in failed: \(authError)")
                }
            }, receiveValue: { result in
                self.isAuthenticated = result.isSignedIn
                print("✅ Sign in success")
            })
            .store(in: &cancellables)
        }

//    func signOut() {
//        Amplify.Auth.signOut { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    self.isAuthenticated = false
//                    self.isGuest = false
//                    self.clearProfile()
//                    print("🚪 Signed out")
//                case .failure(let error):
//                    print("❌ Sign out failed: \(error)")
//                }
//            }
//        }
//    }

    // MARK: - Session Check
//    func checkAuthSession() {
//        _ = Amplify.Auth.fetchAuthSession { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let session):
//                    self.isAuthenticated = session.isSignedIn
//                    print("🔐 Session state: \(session.isSignedIn)")
//                case .failure(let error):
//                    print("❌ Auth session check failed: \(error)")
//                    self.isAuthenticated = false
//                }
//            }
//        }
//    }

    // MARK: - Sign in with Apple (to be expanded)
    func handleAppleSignIn(credential: ASAuthorizationAppleIDCredential) {
        // Use credential.identityToken, credential.user, etc.
        print("🍎 Apple Sign-In Placeholder — Credential received")
        // You may want to call Amplify.Auth.signInWithWebUI for federated login
    }
}

