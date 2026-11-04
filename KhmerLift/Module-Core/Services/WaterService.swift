//
//  WaterService.swift
//  KhmerLift
//
//  Created by Panha on 3/11/26.
//

import Foundation

protocol WaterServiceProtocol {
    func saveWaterLog(_ amount: Double) throws
    func fetchTodayWaterLogs() -> [WaterLog]
    func fetchTotalWaterToday() -> Double
    
    func saveWaterGoal(_ goal: Double)
    func fetchWaterGoal() -> Double
}

final class WaterService: WaterServiceProtocol {
    private let storageKey = "saved_water_logs_key"
    private let goalKey = "saved_water_goal_key"
    private let userDefaults = UserDefaults.standard
    
    func saveWaterLog(_ amount: Double) throws {
        var logs = fetchAllLogs()
        let newLog = WaterLog(amount: amount)
        logs.append(newLog)
        
        let data = try JSONEncoder().encode(logs)
        userDefaults.set(data, forKey: storageKey)
    }
    
    func fetchTodayWaterLogs() -> [WaterLog] {
        let calendar = Calendar.current
        return fetchAllLogs().filter { calendar.isDateInToday($0.timestamp) }
    }
    
    func fetchTotalWaterToday() -> Double {
        return fetchTodayWaterLogs().reduce(0) { $0 + $1.amount}
    }
    
    func saveWaterGoal(_ goal: Double) {
        userDefaults.set(goal, forKey: goalKey)
    }
    
    func fetchWaterGoal() -> Double {
        let savedGoal = userDefaults.double(forKey: goalKey)
        return savedGoal > 0 ? savedGoal : 3000.0
    }
    
    private func fetchAllLogs() -> [WaterLog] {
        guard let data = userDefaults.data(forKey: storageKey),
            let logs = try? JSONDecoder().decode([WaterLog].self, from: data) else {
            return []
        }
        return logs
    }
}
