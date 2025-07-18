//
//  HealthArticle.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/16/25.
//

import Foundation

struct HealthArticle: Identifiable, Codable {
    let id = UUID()
    let title: String
    let summary: String
    let imageName: String  // Stored in Assets or URL later
    let link: String       // Optional - where the full article lives
}

