//
//  SwiftDataContainer.swift
//  KhmerLift
//
//  Created by Panha on 1/10/26.
//

import SwiftData

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
