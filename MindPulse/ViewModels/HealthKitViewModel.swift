//
//  HealthKitViewModel.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import Foundation
import HealthKit
import CoreData
import SwiftUI

extension HealthAlertType: Identifiable {
    var id: Int {
        switch self {
        case .requestPermission: return 1
        case .accessDenied: return 2
        }
    }
}


enum HealthAlertType {
    case requestPermission
    case accessDenied
}

class HealthKitViewModel: ObservableObject {
    @Published var stressScore: Int = -1
    @Published var heartRate: Double?
    @Published var hrv: Double?
    @Published var sleepHours: Double?
    @Published var stressHistory: [DailyStress] = []
    //@Published var isAuthorized: Bool = false
    @Published var isDenied: Bool = false
    @Published var showHealthPermissionAlert: Bool = false
    @Published var showDeniedNotice: Bool = false
    @Published var bloodOxygen: Double?
    @Published var respiratoryRate: Double?
    @Published var stepCount: Double?
    @Published var activeCalories: Double?
    
    @Published var activeAlert: HealthAlertType? = nil
    @AppStorage("hasRequestedHealthKit") private var hasRequestedHealthKit: Bool = false
    @AppStorage("isAuthorized") private var isAuthorized: Bool = false
    
    private let context = CoreDataManager.shared.container.viewContext
    
    func checkAuthorizationNeeded() {
        if isAuthorized {
            loadData()
        } else {
            if !hasRequestedHealthKit {
                print(">>> Requesting HealthKit authorization")
                activeAlert = .requestPermission
            }
        }
      }

    func requestHealthAccess() {
        HealthKitManager.shared.requestAuthorization { [weak self] success in
            if success {
                self?.loadData()
                self?.isAuthorized = true
            }else {
                self?.activeAlert = .accessDenied
            }
            
            self?.hasRequestedHealthKit = true
        }
    }
    
    
    func simulateStressHistory() {
        let today = Date()
        stressHistory = (0..<7).map { i in
            let randomScore = Int.random(in: 30...95)
            let date = Calendar.current.date(byAdding: .day, value: -i, to: today)!
            return DailyStress(date: date, score: randomScore)
        }.reversed()
    }
    
    func saveMoodOnlyEntry(_ mood: String) {
        let context = CoreDataManager.shared.container.viewContext
        let entry = JournalEntry(context: context)
        entry.id = UUID()
        entry.date = Date()
        entry.text = ""
        entry.mood = mood
        CoreDataManager.shared.saveContext()
    }
    
    func saveStressScoreIfNew() {
        guard stressScore >= 0 else { return }

        let today = Calendar.current.startOfDay(for: Date())

        // Check if already exists
        let request: NSFetchRequest<StressRecord> = StressRecord.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", today as NSDate)

        if let existing = try? context.fetch(request), existing.isEmpty == false {
            return // already saved today
        }

        let record = StressRecord(context: context)
        record.date = today
        record.score = Int32(stressScore)
        CoreDataManager.shared.saveContext()
    }

    func loadData() {
        fetchHeartRate()
        fetchHRV()
        fetchSleep()
        fetchBloodOxygen()
        fetchRespiratoryRate()
        fetchSteps()
        fetchActiveCalories()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
               self.calculateStressScore()
               self.fetchStressHistory()   // loads for trends view
           }
    }
    
    private func fetchSteps() {
        HealthKitManager.shared.fetchTodayStepCount { steps in
            self.stepCount = steps
        }
    }

    private func fetchActiveCalories() {
        HealthKitManager.shared.fetchTodayActiveEnergy { calories in
            self.activeCalories = calories
        }
    }
    
    func calculateStressScore() {
        stressScore = StressScoreEngine.computeStressScore(
            hrv: self.hrv,
            restingHR: self.heartRate,
            sleepHours: self.sleepHours,
            respiratoryRate: self.respiratoryRate,
            bloodOxygen: self.bloodOxygen
        )
        saveStressScoreIfNew()
        fetchStressHistory() // update chart
    }
    
    private func fetchBloodOxygen() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) else { return }
        HealthKitManager.shared.fetchLatestSample(of: type) { (sample: HKQuantitySample?) in
            DispatchQueue.main.async {
                self.bloodOxygen = sample?.quantity.doubleValue(for: .percent())
            }
        }
    }
    

    private func fetchRespiratoryRate() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else { return }
        HealthKitManager.shared.fetchLatestSample(of: type) { (sample: HKQuantitySample?) in
            DispatchQueue.main.async {
                self.respiratoryRate = sample?.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
            }
        }
    }
    
    func fetchStressHistory() {
        let request: NSFetchRequest<StressRecord> = StressRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        if let records = try? context.fetch(request) {
            stressHistory = records.map {
                DailyStress(date: $0.date, score: Int($0.score))
            }
        }
    }

    func startWatchConnectivityBridge() {
        WatchSessionManager.shared.healthDataHandler = { [weak self] hr, hrv, streesScore, oxygen, respiratoryRate, sleepDuration in
            guard let self = self else { return }
            self.heartRate = hr
            self.hrv = hrv
            self.stressScore = streesScore
            self.bloodOxygen = oxygen
            self.respiratoryRate = respiratoryRate
            self.sleepHours = sleepDuration
            self.calculateStressScore()
        }
    }

    private func fetchHeartRate() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        HealthKitManager.shared.fetchLatestSample(of: type) { (sample: HKQuantitySample?) in
            DispatchQueue.main.async {
                self.heartRate = sample?.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            }
        }
    }

    private func fetchHRV() {
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }
        HealthKitManager.shared.fetchLatestSample(of: type) { (sample: HKQuantitySample?) in
            DispatchQueue.main.async {
                self.hrv = sample?.quantity.doubleValue(for: .secondUnit(with: .milli))
            }
        }
    }

    private func fetchSleep() {
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        HealthKitManager.shared.fetchLatestSample(of: type) { (sample: HKCategorySample?) in
            if let sample = sample {
                let duration = sample.endDate.timeIntervalSince(sample.startDate) / 3600
                DispatchQueue.main.async {
                    self.sleepHours = duration
                }
            }
        }
    }
}

