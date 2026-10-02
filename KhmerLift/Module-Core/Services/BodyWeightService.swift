//
//  BodyWeightService.swift
//  KhmerLift
//
//  Created by Panha on 1/10/26.
//

import SwiftData
import Foundation

@MainActor
protocol BodyWeightServiceProtocol: AnyObject {
    func saveBodyWeight(_ weight: Double) throws
    func fetchLatestBodyWeight() -> Double?
    func fetchAllBodyWeightLogs() -> [BodyWeightLog]
    
    func saveTargetWeight(_ weight: Double)
    func fetchTargetWeight() -> Double
}

@MainActor
final class BodyWeightService: BodyWeightServiceProtocol {
    private let modelContainer: ModelContainer
    private let context: ModelContext
    
    private let targetWeightKey = "targetBodyWeight"

    
    init(modelContainer: ModelContainer? = nil) {
        let container = modelContainer ?? SwiftDataContainer.shared
        self.modelContainer = container
        self.context = container.mainContext
                
        if let url = container.configurations.first?.url {
            print("📍 SwiftData Database Path: \(url.path)")
        }
    }
    
    func saveBodyWeight(_ weight: Double) throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay.addingTimeInterval(86400)
        
        var descriptor = FetchDescriptor<BodyWeightLog>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        descriptor.fetchLimit = 1
        
        if let todayLog = try context.fetch(descriptor).first {
            todayLog.bodyWeight = weight
            todayLog.date = Date()
        } else {
            let newLog = BodyWeightLog(bodyWeight: weight)
            context.insert(newLog)
        }
        
        try context.save()
    }

    func fetchLatestBodyWeight() -> Double? {
        var descriptor = FetchDescriptor<BodyWeightLog>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        
        return try? context.fetch(descriptor).first?.bodyWeight
    }

    func fetchAllBodyWeightLogs() -> [BodyWeightLog] {
        let descriptor = FetchDescriptor<BodyWeightLog>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func saveTargetWeight(_ weight: Double) {
        UserDefaults.standard.set(weight, forKey: targetWeightKey)
    }
    
    func fetchTargetWeight() -> Double {
        let saved = UserDefaults.standard.double(forKey: targetWeightKey)
        return saved > 0 ? saved : 55.0
    }
}

