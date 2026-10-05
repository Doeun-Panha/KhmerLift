//
//  HomeScreenModel.swift
//  KhmerLift
//

import SwiftUI
import SwiftData

protocol SelectableItem: Identifiable, Hashable {
    var name: String { get }
    var displayName: String { get }
}

extension SelectableItem {
    var displayName: String { name }
}

@Model
final class MuscleCategory {
    var id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

extension MuscleCategory: Equatable {
    nonisolated static func == (lhs: MuscleCategory, rhs: MuscleCategory) -> Bool {
        lhs.persistentModelID == rhs.persistentModelID
    }
}

extension MuscleCategory: Hashable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(persistentModelID)
    }
}

extension MuscleCategory: SelectableItem {}

@Model
final class Exercise {
    var id: UUID
    var categoryId: UUID
    var name: String
    
    init(id: UUID = UUID(), categoryId: UUID, name: String) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
    }
}

extension Exercise: Equatable {
    nonisolated static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.persistentModelID == rhs.persistentModelID
    }
}

extension Exercise: Hashable {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(persistentModelID)
    }
}

extension Exercise: SelectableItem {}

@Model
final class BodyWeightLog {
    var id: UUID
    var date: Date
    var bodyWeight: Double
    
    init(
        date: Date = Date(),
        bodyWeight: Double
    ) {
        self.id = UUID()
        self.date = date
        self.bodyWeight = bodyWeight
    }
}

@Model
final class ExerciseLog {
    var id: UUID
    var date: Date
    var exercise: String
    var weight: Double
    var repetition: Int
    
    init(
        date: Date = Date(),
        exercise: String,
        weight: Double,
        repetition: Int
    ) {
        self.id = UUID()
        self.date = date
        self.exercise = exercise
        self.weight = weight
        self.repetition = repetition
    }
}
