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
    @Published var bloodOxygen: Double?
    @Published var respiratoryRate: Double?
    @Published var sleepDuration: TimeInterval?
    @Published var stressScore: Int = -1   // computed later if desired
    @Published var isAuthorized = false
    private var heartRateAnchor: HKQueryAnchor?
    private var hrvAnchor: HKQueryAnchor?
    private var sleepAnchor: HKQueryAnchor?
    private var resRateAnchor: HKQueryAnchor?
    private var oxygenAnchor: HKQueryAnchor?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let healthStore = HKHealthStore()

    // Types we want to read
    private let readTypes: Set<HKSampleType> = {
        var set = Set<HKSampleType>()
        if let hr = HKObjectType.quantityType(forIdentifier: .heartRate) { set.insert(hr) }
        if let hrv = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) { set.insert(hrv) }
        if let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {set.insert(sleepAnalysis)}
        if let resRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate) { set.insert(resRate) }
        if let oxygenSaturation = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) { set.insert(oxygenSaturation)}
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
        fetchQuantityPublisher(for: .heartRate)
               .receive(on: DispatchQueue.main) 
               .sink { [weak self] in self?.heartRate = $0 }
               .store(in: &cancellables)

           fetchQuantityPublisher(for: .heartRateVariabilitySDNN)
               .receive(on: DispatchQueue.main)
               .sink { [weak self] in self?.hrv = $0 }
               .store(in: &cancellables)

           fetchQuantityPublisher(for: .oxygenSaturation)
               .receive(on: DispatchQueue.main)
               .sink { [weak self] in self?.bloodOxygen = $0 }
               .store(in: &cancellables)

           fetchQuantityPublisher(for: .respiratoryRate)
               .receive(on: DispatchQueue.main)
               .sink { [weak self] in self?.respiratoryRate = $0 }
               .store(in: &cancellables)

        // Optional: compute stressScore from HR + HRV (light heuristic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //self.computeStressScore()
            self.stressScore = StressScoreEngine.computeStressScore(
                hrv: self.hrv,
                restingHR: self.heartRate,
                //sleepHours: self.sleepDuration,
                respiratoryRate: self.respiratoryRate,
                bloodOxygen: self.bloodOxygen
            )
        }
    }

    // MARK: - Fetch Helpers
    // MARK: - Fetch Helpers
    private func fetchLatestQuantity(_ id: HKQuantityTypeIdentifier, completion: @escaping (Double?) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: id) else {
            completion(nil)
            return
        }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }

            let unit: HKUnit
            switch id {
            case .heartRate:
                unit = HKUnit.count().unitDivided(by: .minute())
            case .heartRateVariabilitySDNN:
                unit = .secondUnit(with: .milli)
            case .respiratoryRate:
                unit = HKUnit.count().unitDivided(by: .minute())
            case .oxygenSaturation:
                unit = HKUnit.percent()  // Returns value like 0.98 for 98%
            default:
                unit = .count()
            }

            var value = sample.quantity.doubleValue(for: unit)

            // Special case: Convert oxygenSaturation to percentage
            if id == .oxygenSaturation {
                value *= 100.0
            }

            DispatchQueue.main.async {
                completion(value)
            }
        }

        healthStore.execute(query)
    }

    
    private func fetchLatestSleepAnalysis(completion: @escaping (TimeInterval?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil); return
        }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            guard let sample = samples?.first as? HKCategorySample else {
                completion(nil); return
            }

            if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                let duration = sample.endDate.timeIntervalSince(sample.startDate)
                DispatchQueue.main.async { completion(duration) }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }

        healthStore.execute(query)
    }


    private func computeStressScore() {
        guard let hr = heartRate,
              let hrv = hrv else {
            stressScore = -1; return
        }

        let normalizedHR = min(max((hr - 50) / 100, 0), 1)
        let normalizedHRV = 1 - min(max((hrv - 20) / 100, 0), 1)
        
        var score = ((normalizedHR * 0.6) + (normalizedHRV * 0.4)) * 100

        if let rr = respiratoryRate {
            let rrFactor = min(max((rr - 12) / 8, 0), 1)  // assuming 12-20 is normal
            score += rrFactor * 10  // small stress boost if high RR
        }

        if let oxygen = bloodOxygen, oxygen < 95 {
            score += (95 - oxygen) * 1.5  // penalize low SpO2
        }

        stressScore = Int(min(score, 100))
    }
    
    private func sendToiPhone() {
        guard let hr = heartRate, let hrvValue = hrv, let bloodOxygen = bloodOxygen, let respiratoryRate = respiratoryRate, let sleepDuration = sleepDuration else { return }
        let normalizedHR = min(max((hr - 50) / 100, 0), 1)       // 0..1
        let normalizedHRV = 1 - min(max((hrvValue - 20) / 100, 0), 1) // invert
        let score = Int(((normalizedHR * 0.6) + (normalizedHRV * 0.4)) * 100)
        stressScore = score
        WatchSessionManager.shared.sendHealthData(heartRate: hr,
                                                  hrv: hrvValue,
                                                  streesScore: stressScore,
                                                  oxygen: bloodOxygen,
                                                  respiratoryRate: respiratoryRate,
                                                  sleepDuration: sleepDuration)
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
        
        // MARK: - Respiratory Rate
        if let resType = HKObjectType.quantityType(forIdentifier: .respiratoryRate) {
               let query = HKAnchoredObjectQuery(type: resType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] (_, samplesOrNil, _, _, _) in
                   if let samples = samplesOrNil as? [HKQuantitySample], let latest = samples.last {
                       let rr = latest.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
                       DispatchQueue.main.async {
                           self?.respiratoryRate = rr
                           self?.sendToiPhone()
                       }
                   }
               }
               query.updateHandler =  { [weak self] (_, samplesOrNil, _, newAnchor, _) in
                   self?.resRateAnchor = newAnchor
                   if let samples = samplesOrNil as? [HKQuantitySample], let latest = samples.last {
                       let value = latest.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                       DispatchQueue.main.async {
                           self?.respiratoryRate = value
                           self?.sendToiPhone()
                       }
                   }
               }
               healthStore.execute(query)
           }
        
        // MARK: - Blood Oxygen
        if let oxygenType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) {
               let query = HKAnchoredObjectQuery(type: oxygenType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] (_, samplesOrNil, _, _, _) in
                   if let samples = samplesOrNil as? [HKQuantitySample], let latest = samples.last {
                       let oxygen = latest.quantity.doubleValue(for: .percent()) * 100
                       DispatchQueue.main.async {
                           self?.bloodOxygen = oxygen
                           self?.sendToiPhone()
                       }
                   }
               }
               query.updateHandler = { [weak self] (_, samplesOrNil, _, newAnchor, _) in
                   self?.resRateAnchor = newAnchor
                   if let samples = samplesOrNil as? [HKQuantitySample], let latest = samples.last {
                       let value = latest.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                       DispatchQueue.main.async {
                           self?.bloodOxygen = value
                           self?.sendToiPhone()
                       }
                   }
               }
               healthStore.execute(query)
           }
    }
}

extension WatchHealthViewModel {
    func fetchQuantityPublisher(for identifier: HKQuantityTypeIdentifier) -> AnyPublisher<Double?, Never> {
        Future { promise in
            guard let type = HKObjectType.quantityType(forIdentifier: identifier) else {
                promise(.success(nil))
                return
            }

            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    promise(.success(nil))
                    return
                }

                let unit: HKUnit
                switch identifier {
                case .heartRate:
                    unit = HKUnit.count().unitDivided(by: .minute())
                case .heartRateVariabilitySDNN:
                    unit = .secondUnit(with: .milli)
                case .respiratoryRate:
                    unit = HKUnit.count().unitDivided(by: .minute())
                case .oxygenSaturation:
                    unit = HKUnit.percent()
                default:
                    unit = HKUnit.count()
                }

                let value = sample.quantity.doubleValue(for: unit)
                promise(.success(value))
            }

            self.healthStore.execute(query)
        }
        .eraseToAnyPublisher()
    }
}

