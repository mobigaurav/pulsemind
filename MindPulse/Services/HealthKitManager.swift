//
//  HealthKitManager.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import HealthKit

extension HealthKitManager {
    func fetchTodayStepCount(completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        fetchSumForToday(of: type, unit: .count(), completion: completion)
    }
    
    func fetchTodayActiveEnergy(completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        fetchSumForToday(of: type, unit: .kilocalorie(), completion: completion)
    }
    
    private func fetchSumForToday(of type: HKQuantityType, unit: HKUnit, completion: @escaping (Double) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            DispatchQueue.main.async {
                completion(value)
            }
        }
        healthStore.execute(query)
    }
    
    func observeSample(type: HKSampleType, updateHandler: @escaping () -> Void) {
        let query = HKObserverQuery(sampleType: type, predicate: nil) { _, _, error in
            if error != nil {
                print("Observer error: \(error!.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                updateHandler()
            }
        }
        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { success, error in
            if !success {
                print("Failed enabling background delivery: \(String(describing: error))")
            }
        }
    }

}


final class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private init() {}

    let readTypes: Set<HKSampleType> = Set([
        HKObjectType.quantityType(forIdentifier: .heartRate),
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
        HKObjectType.quantityType(forIdentifier: .respiratoryRate),
        HKObjectType.quantityType(forIdentifier: .oxygenSaturation),
        HKObjectType.quantityType(forIdentifier: .stepCount),
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
    ].compactMap { $0 })

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    func fetchLatestSample<T: HKSample>(of type: HKSampleType, completion: @escaping (T?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            completion(samples?.first as? T)
        }
        healthStore.execute(query)
    }
}

