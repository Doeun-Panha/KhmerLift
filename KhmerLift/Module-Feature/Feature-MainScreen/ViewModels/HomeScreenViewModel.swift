//
//  HomeScreenViewModel.swift
//  KhmerLift
//
//  Created by Panha on 21/9/26.
//

import SwiftUI

@Observable
final class HomeScreenViewModel {
    var title: String = "KhmerLift"
    var streak: Int = 0
    
    var bodyWeight: Double = 0.0
    var weight: Double = 0.0
    var repetition: Int = 0
    
    var bodyWeightString: String {
        get { bodyWeight == 0 ? "" : String(bodyWeight) }
        set {
            if let parsed = Double(newValue) {
                bodyWeight = parsed
            } else if newValue.isEmpty {
                bodyWeight = 0.0
            }
        }
    }
    
    var weightString: String {
        get { weight == 0 ? "" : String(weight) }
        set {
            if let parsed = Double(newValue) {
                weight = parsed
            } else if newValue.isEmpty {
                weight = 0.0
            }
        }
    }
    
    var repetitionString: String {
        get { repetition == 0 ? "" : String(repetition) }
        set {
            if let parsed = Int(newValue) {
                repetition = parsed
            } else if newValue.isEmpty {
                repetition = 0
            }
        }
    }
    
    var categories: [MuscleCategory] = []
    var exercises: [Exercise] = []
    
    var selectedMuscle: MuscleCategory? {
        didSet {
            if oldValue?.id != selectedMuscle?.id {
                selectedExercise = nil
            }
        }
    }
    
    var selectedExercise: Exercise?
    
    var filteredExercises: [Exercise] {
        guard let selectedMuscle else { return [] }
        return exercises.filter { $0.categoryId == selectedMuscle.id }
    }
    
    init() {
        seedInitialData()
    }
    
    private func seedInitialData() {
        let chest = MuscleCategory(name: "Chest")
        let back = MuscleCategory(name: "Back")
        let legs = MuscleCategory(name: "Legs")
        
        self.categories = [chest, back, legs]
        self.exercises = [
            Exercise(categoryId: chest.id, name: "Incline Barbell Press"),
            Exercise(categoryId: chest.id, name: "Flat Dumbbell Fly"),
            Exercise(categoryId: back.id, name: "Lat Pulldown"),
            Exercise(categoryId: back.id, name: "Bent Over Row"),
            Exercise(categoryId: legs.id, name: "Barbell Back Squat")
        ]
    }
}
