//
//  ContentView.swift
//  Shared
//
//  Created by Mohammad Azam on 7/13/20.
//

import SwiftUI
import HealthKit

struct Step: Identifiable {
    let id = UUID()
    let count: Int
    let date: Date
}
struct GraphView: View {
    var steps: [Step]

    var body: some View {
        List(steps, id: \.id) { step in
            VStack(alignment: .leading) {
                Text("Steps: \(step.count)")
                Text("Date: \(step.date, style: .date)")
            }
        }
    }
}

struct HealthManagerView: View {
    
    private var healthStore: HealthStore?
    @State private var steps: [Step] = [Step]()
    
    init() {
        healthStore = HealthStore()
    }
    
    private func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection) {
        
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let endDate = Date()
        
        statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
            
            let count = statistics.sumQuantity()?.doubleValue(for: .count())
            
            let step = Step(count: Int(count ?? 0), date: statistics.startDate)
            steps.append(step)
        }
        
    }
    
    var body: some View {
        
        NavigationView {
        
        GraphView(steps: steps)
            
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

