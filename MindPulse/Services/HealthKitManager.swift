//
//  HealthKitManager.swift
//  MindPulse
//
//  Created by Gaurav Kumar on 7/13/25.
//

import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    private init() {}

    let readTypes: Set<HKSampleType> = Set([
        HKObjectType.quantityType(forIdentifier: .heartRate),
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
        HKObjectType.quantityType(forIdentifier: .respiratoryRate),
        HKObjectType.quantityType(forIdentifier: .oxygenSaturation)
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

