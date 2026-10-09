//
//  StreakService.swift
//  KhmerLift
//
//  Created by Panha on 9/10/26.
//

import Foundation

struct StreakStatus {
    let count: Int
    let isLoggedToday: Bool
}

@MainActor
protocol StreakServiceProtocol: AnyObject {
    func fetchStreakStatus() -> StreakStatus
}

@MainActor
final class StreakService: StreakServiceProtocol {
    private let bodyWeightService: BodyWeightServiceProtocol
    private let exerciseService: ExerciseServiceProtocol
    
    init(
        bodyWeightService: BodyWeightServiceProtocol? = nil,
        exerciseService: ExerciseServiceProtocol? = nil
    ) {
        self.bodyWeightService = bodyWeightService ?? BodyWeightService()
        self.exerciseService = exerciseService ?? ExerciseService()
    }
    
    func fetchStreakStatus() -> StreakStatus {
        let calendar = Calendar.current
        
        let weightDates = bodyWeightService.fetchAllBodyWeightLogs().map { $0.date }
        let exerciseDates = exerciseService.fetchAllExerciseLogs().map { $0.date }
        
        let activeDays = Set((weightDates + exerciseDates).map { calendar.startOfDay(for: $0) })
        
        let today = calendar.startOfDay(for: Date())
        let isLoggedToday = activeDays.contains(today)
        
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return StreakStatus(count: 0, isLoggedToday: false) }
        
        var checkDate: Date?
        if activeDays.contains(today) {
            checkDate = today
        } else if activeDays.contains(yesterday) {
            checkDate = yesterday
        } else {
            return StreakStatus(count: 0, isLoggedToday: false)
        }
        
        var streak = 0
        var currentDay = checkDate
        
        while let day = currentDay, activeDays.contains(day) {
            streak += 1
            currentDay = calendar.date(byAdding: .day, value: -1, to: day)
        }
        
        return StreakStatus(count: streak, isLoggedToday: isLoggedToday)
    }
}
