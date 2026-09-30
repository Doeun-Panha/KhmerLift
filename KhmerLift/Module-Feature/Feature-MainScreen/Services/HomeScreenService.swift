//
//  HomeScreenService.swift
//  KhmerLift
//
//  Created by Panha on 28/9/26.
//

import SwiftData
import Foundation

@MainActor
protocol HomeScreenServiceProtocol: AnyObject {
    func saveBodyWeight(_ weight: Double) throws
    func fetchLatestBodyWeight() -> Double?
    func fetchAllBodyWeightLogs() -> [BodyWeightLog]
    
    func saveExerciseLog(exercise: String, weight: Double, repetition: Int) throws
    func fetchLatestExerciseLog(for exercise: String) -> ExerciseLog?
    func fetchAllExerciseLogs() -> [ExerciseLog]
    
    func saveCategory(_ category: MuscleCategory) throws
    func fetchCategories() throws -> [MuscleCategory]
    
    func saveExercise(_ exercise: Exercise) throws
    func fetchExercises() throws -> [Exercise]
}

@MainActor
final class HomeScreenService: HomeScreenServiceProtocol {
    private let modelContainer: ModelContainer
    private let context: ModelContext
    
    init(modelContainer: ModelContainer? = nil) {
        let container = modelContainer ?? SwiftDataContainer.shared
        self.modelContainer = container
        self.context = container.mainContext
        
        try? seedInitialDataIfNeeded()
        
//        if let url = container.configurations.first?.url {
//            print("📍 SwiftData Database Path: \(url.path)")
//        }
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
        
    func saveExerciseLog(exercise: String, weight: Double, repetition: Int) throws {
        let newLog = ExerciseLog(
            exercise: exercise,
            weight: weight,
            repetition: repetition
        )
        context.insert(newLog)
        try context.save()
    }
    
    func fetchLatestExerciseLog(for exercise: String) -> ExerciseLog? {
        var descriptor = FetchDescriptor<ExerciseLog>(
            predicate: #Predicate { $0.exercise == exercise },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }
    
    func fetchAllExerciseLogs() -> [ExerciseLog] {
        let descriptor = FetchDescriptor<ExerciseLog>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func saveCategory(_ category: MuscleCategory) throws {
        context.insert(category)
        try context.save()
    }
    
    func fetchCategories() throws -> [MuscleCategory] {
        let descriptor = FetchDescriptor<MuscleCategory>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        return try context.fetch(descriptor)
    }
    
    func saveExercise(_ exercise: Exercise) throws {
        context.insert(exercise)
        try context.save()
    }
    
    func fetchExercises() throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        return try context.fetch(descriptor)
    }
    
    private func seedInitialDataIfNeeded() throws {
        let existingCategories = try fetchCategories()
        guard existingCategories.isEmpty else { return }
        
        let chest = MuscleCategory(name: "Chest")
        let back = MuscleCategory(name: "Back")
        let legs = MuscleCategory(name: "Legs")
        
        context.insert(chest)
        context.insert(back)
        context.insert(legs)
        
        let defaultExercises = [
            Exercise(categoryId: chest.id, name: "Incline Barbell Press"),
            Exercise(categoryId: chest.id, name: "Flat Dumbbell Fly"),
            Exercise(categoryId: back.id, name: "Lat Pulldown"),
            Exercise(categoryId: back.id, name: "Bent Over Row"),
            Exercise(categoryId: legs.id, name: "Barbell Back Squat")
        ]
        
        for exercise in defaultExercises {
            context.insert(exercise)
        }
        
        try context.save()
    }
}

final class SwiftDataContainer: Sendable {
    static let shared: ModelContainer = {
        let schema = Schema([
            BodyWeightLog.self,
            ExerciseLog.self,
            MuscleCategory.self,
            Exercise.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
