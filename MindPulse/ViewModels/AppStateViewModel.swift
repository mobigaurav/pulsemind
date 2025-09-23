//
//  AppStateViewModel.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 8/22/25.
//

import Foundation
import SwiftUI

class AppStateViewModel: ObservableObject {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("isGuest") var isGuest: Bool = false
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    @Published var destination: LaunchDestination = .onboarding

    init() {
        DispatchQueue.main.async {
               self.evaluateLaunchDestination()
           }
    }

    func evaluateLaunchDestination() {
        if !hasSeenOnboarding {
            destination = .onboarding
        } else if isLoggedIn || isGuest {
            destination = .mainApp
        } else {
            destination = .welcome
        }
    }
}
