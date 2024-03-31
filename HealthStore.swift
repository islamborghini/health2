//
//  HealthStore.swift
//  JustWalking
//
//  Created by Mohammad Azam on 7/13/20.
//

import Foundation
import HealthKit

extension Date {
    static func mondayAt12AM() -> Date {
        return Calendar(identifier: .iso8601).date(from: Calendar(identifier: .iso8601).dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }
}

class HealthStore {
    
    var healthStore: HKHealthStore?
    var query: HKStatisticsCollectionQuery?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    func calculateSteps(completion: @escaping (HKStatisticsCollection?) -> Void) {
        
        let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        let startDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        
        let anchorDate = Date.mondayAt12AM()
        
        let daily = DateComponents(day: 1)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        query = HKStatisticsCollectionQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: daily)
        
        query!.initialResultsHandler = { query, statisticsCollection, error in
            completion(statisticsCollection)
        }
        
        if let healthStore = healthStore, let query = self.query {
            healthStore.execute(query)
        }
        
    }
    func calculateSleep(completion: @escaping ([HKCategorySample]?) -> Void) {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

        let startDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, result, error) in
            guard let samples = result as? [HKCategorySample] else {
                completion(nil)
                return
            }
            completion(samples)
        }

        healthStore?.execute(query)
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        
        let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

        guard let healthStore = self.healthStore else { return completion(false) }
        
        healthStore.requestAuthorization(toShare: [], read: [stepType, sleepType]) { (success, error) in
            completion(success)
        }
        
    }
    
}
