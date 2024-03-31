//
//  ContentView.swift
//  Shared
//
//  Created by Islam Assanov on 7/13/20.
//

import SwiftUI
import HealthKit

struct Step: Identifiable {
    let id = UUID()
    let count: Int
    let date: Date
}
struct Sleep: Identifiable {
    let id = UUID()
    let duration: TimeInterval
    let startDate: Date
    let endDate: Date
}

struct GraphView: View {
    var steps: [Step]
    var sleepData: [Sleep]
    
    var body: some View {
        List {
                    Section(header: Text("Steps")) {
                        ForEach(steps, id: \.id) { step in
                            VStack(alignment: .leading) {
                                Text("Steps: \(step.count)")
                                Text("Date: \(step.date, style: .date)")
                            }
                        }
                    }

                    Section(header: Text("Sleep")) {
                        ForEach(sleepData, id: \.id) { sleep in
                            VStack(alignment: .leading) {
                                Text("Duration: \(sleep.duration/10000, specifier: "%.2f") hours")
                                Text("From: \(sleep.startDate, style: .time)")
                                Text("To: \(sleep.endDate, style: .time)")
                            }
                        }
                    }
                }
    }
}

struct HealthManagerView: View {
    
    private var healthStore: HealthStore?
    @State private var steps: [Step] = [Step]()
    @State private var sleepData: [Sleep] = [Sleep]()
    init() {
        healthStore = HealthStore()
    }
    
    private func updateSleepData(from samples: [HKCategorySample]) {
        self.sleepData = samples.map { sample in
            Sleep(duration: sample.endDate.timeIntervalSince(sample.startDate), startDate: sample.startDate, endDate: sample.endDate)
        }
    }
    
    
    private func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection) {
        
        let startDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let endDate = Date()
        
        statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
            
            let count = statistics.sumQuantity()?.doubleValue(for: .count())
            
            let step = Step(count: Int(count ?? 0), date: statistics.startDate)
            steps.append(step)
        }
        
    }
    
    var body: some View {
        
        NavigationView {
        
        GraphView(steps: steps, sleepData: sleepData)
                .navigationTitle("Your data")

            
        .navigationTitle("Just Walking")
        }
       
        
            .onAppear {
                if let healthStore = healthStore {
                    healthStore.requestAuthorization { success in
                        if success {
                            healthStore.calculateSteps { statisticsCollection in
                                if let statisticsCollection = statisticsCollection {
                                    // update the UI
                                    updateUIFromStatistics(statisticsCollection)
                                }
                            }
                            healthStore.calculateSleep { sleepSamples in
                                if let sleepSamples = sleepSamples {
                                    // Update the UI
                                    updateSleepData(from: sleepSamples)
                                }}
                        }
                    }
                }
            }
        
        
    }
}

struct HealthManagerView_Previews: PreviewProvider {
    static var previews: some View {
        HealthManagerView()
    }
}
