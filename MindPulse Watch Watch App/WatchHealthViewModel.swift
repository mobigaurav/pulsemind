//
//  WatchHealthViewModel.swift
//  MindPulse Watch Watch App
//
//  Created by Gaurav Kumar on 7/16/25.
//

// WatchHealthViewModel.swift (add to Watch Extension target)
import Foundation
import HealthKit
import Combine

final class WatchHealthViewModel: ObservableObject {
    @Published var heartRate: Double?
    @Published var hrv: Double?
    @Published var stressScore: Int = -1   // computed later if desired
    @Published var isAuthorized = false
    private var heartRateAnchor: HKQueryAnchor?
    private var hrvAnchor: HKQueryAnchor?
    private let healthStore = HKHealthStore()

    // Types we want to read
    private let readTypes: Set<HKSampleType> = {
        var set = Set<HKSampleType>()
        if let hr = HKObjectType.quantityType(forIdentifier: .heartRate) { set.insert(hr) }
        if let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) { set.insert(hrv) }
        return set
    }()

    // MARK: - Public API
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success {
                    self.loadData()
                    self.startLiveMonitoring()
                }
            }
        }
    }

    func loadData() {
        fetchLatestQuantity(.heartRate) { self.heartRate = $0 }
        fetchLatestQuantity(.heartRateVariabilitySDNN) { self.hrv = $0 }
        // Optional: compute stressScore from HR + HRV (light heuristic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.computeStressScore()
        }
    }

    // MARK: - Fetch Helpers
    private func fetchLatestQuantity(_ id: HKQuantityTypeIdentifier, completion: @escaping (Double?) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: id) else {
            completion(nil); return
        }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let q = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            guard
                let sample = samples?.first as? HKQuantitySample
            else { completion(nil); return }

            let unit: HKUnit
            switch id {
            case .heartRate:
                unit = HKUnit.count().unitDivided(by: .minute())
            case .heartRateVariabilitySDNN:
                unit = .secondUnit(with: .milli)
            default:
                unit = .count()
            }
            let value = sample.quantity.doubleValue(for: unit)
            DispatchQueue.main.async { completion(value) }
        }
        healthStore.execute(q)
    }

    private func computeStressScore() {
        guard let hr = heartRate, let hrv = hrv else { stressScore = -1; return }
        // trivial heuristic: higher HR + lower HRV -> higher stress
        let normalizedHR = min(max((hr - 50) / 100, 0), 1)       // 0..1
        let normalizedHRV = 1 - min(max((hrv - 20) / 100, 0), 1) // invert
        let score = Int(((normalizedHR * 0.6) + (normalizedHRV * 0.4)) * 100)
        
        stressScore = score
    }
    
    private func sendToiPhone() {
        guard let hr = heartRate, let hrvValue = hrv else { return }
        let normalizedHR = min(max((hr - 50) / 100, 0), 1)       // 0..1
        let normalizedHRV = 1 - min(max((hrvValue - 20) / 100, 0), 1) // invert
        let score = Int(((normalizedHR * 0.6) + (normalizedHRV * 0.4)) * 100)
        stressScore = score
        WatchSessionManager.shared.sendHealthData(heartRate: hr, hrv: hrvValue, streesScore: stressScore)
    }

    
    func startLiveMonitoring() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        if let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) {
            let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: heartRateAnchor, limit: HKObjectQueryNoLimit) { [weak self] (_, samplesOrNil, _, newAnchor, _) in
                self?.heartRateAnchor = newAnchor
                if let samples = samplesOrNil as? [HKQuantitySample], let latest = samples.last {
                    let bpm = latest.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    DispatchQueue.main.async {
                        self?.heartRate = bpm
                        self?.sendToiPhone()
                    }
                }
            }
            query.updateHandler = { [weak self] (_, samplesOrNil, _, newAnchor, _) in
                self?.heartRateAnchor = newAnchor
                if let samples = samplesOrNil as? [HKQuantitySample], let latest = samples.last {
                    let bpm = latest.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    DispatchQueue.main.async {
                        self?.heartRate = bpm
                        self?.sendToiPhone()
                    }
                }
            }
            healthStore.execute(query)
        }

        if let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            let query = HKAnchoredObjectQuery(type: hrvType, predicate: nil, anchor: hrvAnchor, limit: HKObjectQueryNoLimit) { [weak self] (_, samplesOrNil, _, newAnchor, _) in
                self?.hrvAnchor = newAnchor
                if let samples = samplesOrNil as? [HKQuantitySample], let latest = samples.last {
                    let value = latest.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                    DispatchQueue.main.async {
                        self?.hrv = value
                        self?.sendToiPhone()
                    }
                }
            }
            query.updateHandler = { [weak self] (_, samplesOrNil, _, newAnchor, _) in
                self?.hrvAnchor = newAnchor
                if let samples = samplesOrNil as? [HKQuantitySample], let latest = samples.last {
                    let value = latest.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                    DispatchQueue.main.async {
                        self?.hrv = value
                        self?.sendToiPhone()
                    }
                }
            }
            healthStore.execute(query)
        }
    }
}

