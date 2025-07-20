//
//  StressScoreEngine.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//
import Foundation

struct StressScoreEngine {
    static func computeStressScore(
        hrv: Double?,
        restingHR: Double?,
        sleepHours: Double? = nil,
        respiratoryRate: Double? = nil,
        bloodOxygen: Double? = nil
    ) -> Int {
        guard let hrv = hrv, let restingHR = restingHR else {
            return -1
        }

        let normalizedHRV = 1.0 - min(max(hrv / 100.0, 0.0), 1.0)
        let normalizedHR = min(max((restingHR - 50.0) / 70.0, 0.0), 1.0)

        var weightSum = 0.0
        var weightedScore = 0.0

        // HRV
        weightedScore += 0.4 * normalizedHRV
        weightSum += 0.4

        // HR
        weightedScore += 0.4 * normalizedHR
        weightSum += 0.4

        // Sleep (only if available)
        if let sleep = sleepHours {
            let normalizedSleep = 1.0 - min(max(sleep / 8.0, 0.0), 1.0)
            weightedScore += 0.2 * normalizedSleep
            weightSum += 0.2
        }

        var score = (weightedScore / weightSum) * 100

        // Add respiratory rate factor
        if let rr = respiratoryRate {
            let rrFactor = min(max((rr - 12) / 8.0, 0.0), 1.0)
            score += rrFactor * 10
        }

        // Penalize low blood oxygen
        if let oxygen = bloodOxygen, oxygen < 95 {
            score += (95 - oxygen) * 1.5
        }

        return Int(min(score.rounded(), 100))
    }
}



