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
        sleepDate: Date? = nil,
        respiratoryRate: Double? = nil,
        bloodOxygen: Double? = nil
    ) -> Int {
        guard let hrv = hrv, let restingHR = restingHR else {
            return -1 // Missing required data
        }

        // Normalize HRV: lower HRV = higher stress
        let normalizedHRV = 1.0 - min(max(hrv / 100.0, 0.0), 1.0)
        
        // Normalize Heart Rate: higher HR = higher stress
        let normalizedHR = min(max((restingHR - 50.0) / 70.0, 0.0), 1.0)

        var weightedScore = 0.0
        var weightSum = 0.0

        // HRV (weight 40%)
        weightedScore += 0.4 * normalizedHRV
        weightSum += 0.4

        // Heart Rate (weight 40%)
        weightedScore += 0.4 * normalizedHR
        weightSum += 0.4

        // Sleep (weight 20%, only if recent and available)
        if let sleep = sleepHours,
           let date = sleepDate,
           Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date) {

            let normalizedSleep = 1.0 - min(max(sleep / 8.0, 0.0), 1.0)
            weightedScore += 0.2 * normalizedSleep
            weightSum += 0.2
        }

        // Base score: scale to 0–100
        var score = (weightedScore / weightSum) * 100

        // Respiratory Rate bonus: + up to 10 points
        if let rr = respiratoryRate {
            let rrFactor = min(max((rr - 12) / 8.0, 0.0), 1.0)
            score += rrFactor * 10.0
        }

        // Low blood oxygen penalty: + up to 7.5 points
        if let oxygen = bloodOxygen, oxygen < 95 {
            score += min((95 - oxygen) * 1.5, 7.5)
        }

        // Clamp to 0–100
        return Int(min(max(score.rounded(), 0), 100))
    }
}




