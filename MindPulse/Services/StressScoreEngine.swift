//
//  StressScoreEngine.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import Foundation

struct StressScoreEngine {
    /// Ranges based on general population, should be individualized later
    static func computeStressScore(hrv: Double?, restingHR: Double?, sleepHours: Double?) -> Int {
        guard let hrv = hrv, let restingHR = restingHR, let sleepHours = sleepHours else {
            return -1 // insufficient data
        }

        // Normalize each metric to 0–1 range
        let normalizedHRV = 1.0 - min(max(hrv / 100.0, 0.0), 1.0) // higher HRV = less stress
        let normalizedHR = min(max((restingHR - 50.0) / 70.0, 0.0), 1.0) // higher HR = more stress
        let normalizedSleep = 1.0 - min(max(sleepHours / 8.0, 0.0), 1.0) // more sleep = less stress

        // Weights (adjustable later)
        let w1 = 0.4 // HRV
        let w2 = 0.4 // HR
        let w3 = 0.2 // Sleep

        let score = (w1 * normalizedHRV + w2 * normalizedHR + w3 * normalizedSleep) * 100
        return Int(score.rounded())
    }
}

