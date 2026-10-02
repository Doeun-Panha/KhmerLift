//
//  ProgressScreenViewModel.swift
//  KhmerLift
//
//  Created by Panha on 30/9/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ProgressScreenViewModel {
    private let bodyWeightService: BodyWeightServiceProtocol
    
    var summary: BodyWeightSummary = BodyWeightSummary()
    
    init(bodyWeightService: BodyWeightServiceProtocol? = nil) {
        self.bodyWeightService = bodyWeightService ?? BodyWeightService()
    }
    
    func loadSummary() {
        let targetWeight = bodyWeightService.fetchTargetWeight()
        let logs = bodyWeightService.fetchAllBodyWeightLogs()
        
        let latestLog = logs.first
        let currentWeight = latestLog?.bodyWeight
        let latestLogDate = latestLog?.date
        
        let changeResult = calculateMonthlyChange(from: logs)
        
        let chartLogs = Array(logs.prefix(30).reversed())
        
        self.summary = BodyWeightSummary(
            currentWeight: currentWeight,
            latestLogDate: latestLogDate,
            monthlyChange: changeResult?.change,
            comparisonDate: changeResult?.date,
            targetWeight: targetWeight,
            recentLogs: chartLogs
        )
    }
    
    private func calculateMonthlyChange(from logs: [BodyWeightLog]) -> (change: Double, date: Date)? {
        guard let current = logs.first?.bodyWeight else { return nil }
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        if let pastLog = logs.first(where: { $0.date <= thirtyDaysAgo }) {
            return (current - pastLog.bodyWeight, pastLog.date)
        }
        else if let oldestLog = logs.last, oldestLog.id != logs.first?.id {
            return (current - oldestLog.bodyWeight, oldestLog.date)
        }
        
        return nil
    }
    
    func saveNewTargetWeight(_ newTarget: Double) {
        bodyWeightService.saveTargetWeight(newTarget)
        loadSummary()
    }
    
    var formattedCurrentTitle: String {
        guard let date = summary.latestLogDate else { return "Current" }
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        return "Current (\(day)/\(month))"
    }
    
    var formattedCurrentWeight: String {
        guard let weight = summary.currentWeight else { return "-- kg" }
        return String(format: "%.1f kg", weight)
    }
    
    var formattedTargetWeight: String {
        let target = summary.targetWeight
        return String(format: "%.1f kg", target)
    }
    
    var formattedChangeTitle: String {
        guard let date = summary.comparisonDate else { return "Change" }
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        return "Since (\(day)/\(month))"
    }
    
    var formattedMonthlyChange: String {
        guard let change = summary.monthlyChange else { return "-- kg" }
        let sign = change > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", change)) kg"
    }
}
