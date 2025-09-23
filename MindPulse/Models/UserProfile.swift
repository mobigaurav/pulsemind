//
//  UserProfile.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 8/19/25.
//

import Foundation

struct UserProfile: Codable {
    var id:String
    var nickname: String
    var ageRange: String
    var gender: String
    var wellnessGoal: String
}
