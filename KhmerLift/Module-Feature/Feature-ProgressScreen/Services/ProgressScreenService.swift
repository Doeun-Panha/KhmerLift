//
//  ProgressScreenService.swift
//  KhmerLift
//
//  Created by Panha on 30/9/26.
//

import Foundation
import SwiftData

@MainActor
protocol ProgressScreenServiceProtocol: AnyObject {
    func fetchBodyWeightSummary() -> BodyWeightSummary
}

@MainActor
final class ProgressScreenService: ProgressScreenServiceProtocol {
    private let context: ModelContext
    
    init(modelContainer: ModelContainer? = nil) {
        let container = modelContainer ?? SwiftDataContainer.shared
        self.context = container.mainContext
    }
    
    func fetchBodyWeightSummary() -> BodyWeightSummary {
        let descriptor = FetchDescriptor<BodyWeightLog>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let logs = (try? context.fetch(descriptor)) ?? []
        
        let current = logs.first?.bodyWeight
        
        var monthlyChange: Double? = nil
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        if let latestWeight = current, let previousLog = logs.first(where: { $0.date <= thirtyDaysAgo}) {
            monthlyChange = latestWeight - previousLog.bodyWeight
        }
        
        let targetWeight = 80.0
        
        return BodyWeightSummary(currentWeight: current, monthlyChange: monthlyChange, targetWeight: targetWeight)
    }
}
