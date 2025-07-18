//
//  DailyStress.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/14/25.
//

import Foundation

struct DailyStress: Identifiable {
    let id = UUID()
    let date: Date
    let score: Int
}

