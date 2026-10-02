//
//  HomeScreenViewModel.swift
//  KhmerLift
//
//  Created by Panha on 28/9/26.
//

import SwiftUI

@MainActor
@Observable
final class HomeScreenViewModel {
    private let bodyWeightService: BodyWeightServiceProtocol
    private let exerciseService: ExerciseServiceProtocol
    
    var title: String = "KhmerLift"
    
    var bodyWeight: Double = 0.0
    var bodyWeightString: String {
        get { bodyWeight == 0 ? "" : String(bodyWeight) }
        set {
            if let parsed = Double(newValue) { bodyWeight = parsed }
            else if newValue.isEmpty { bodyWeight = 0.0 }
        }
    }
    
    var isBodyWeightValid: Bool {
        bodyWeight > 0
    }
    
    var categories: [MuscleCategory] = []
    var selectedMuscle: MuscleCategory? {
        didSet {
            if oldValue?.id != selectedMuscle?.id {
                selectedExercise = nil
                latestExerciseLog = nil
                weight = 0.0
                repetition = 0
            }
        }
    }
    
    var exercises: [Exercise] = []
    var selectedExercise: Exercise? {
        didSet {
            updateLatestLogAndAutoPopulate()
        }
    }
    
    private(set) var latestExerciseLog: ExerciseLog?
    
    var filteredExercises: [Exercise] {
        guard let selectedMuscle else { return [] }
        return exercises.filter { $0.categoryId == selectedMuscle.id }
    }
    
    var isExerciseSetValid: Bool {
        selectedExercise != nil && weight > 0 && repetition > 0
    }
    
    var previousSetSummary: String? {
        guard let lastLog = latestExerciseLog else { return nil }
        
        let formattedWeight = lastLog.weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", lastLog.weight)
            : String(format: "%.1f", lastLog.weight)
        
        return "Previous: \(formattedWeight) kg × \(lastLog.repetition) reps"
    }
    
    var weight: Double = 0.0
    var weightString: String {
        get { weight == 0 ? "" : String(weight) }
        set {
            if let parsed = Double(newValue) { weight = parsed }
            else if newValue.isEmpty { weight = 0.0 }
        }
    }
    
    var repetition: Int = 0
    var repetitionString: String {
        get { repetition == 0 ? "" : String(repetition) }
        set {
            if let parsed = Int(newValue) { repetition = parsed }
            else if newValue.isEmpty { repetition = 0 }
        }
    }
    
    var toastMessage: String?
    var isToastError: Bool = false
    
    init(
        bodyWeightService: BodyWeightServiceProtocol? = nil,
        exerciseService: ExerciseServiceProtocol? = nil
    ) {
        let bodyWeightService = bodyWeightService ?? BodyWeightService()
        self.bodyWeightService = bodyWeightService

        
        let exerciseService = exerciseService ?? ExerciseService()
        self.exerciseService = exerciseService

        
        loadInitialDataAndPreFill()
    }
    
    private func loadInitialDataAndPreFill() {
        self.categories = (try? exerciseService.fetchCategories()) ?? []
        self.exercises = (try? exerciseService.fetchExercises()) ?? []
        
        if let latestBodyWeight = bodyWeightService.fetchLatestBodyWeight() {
            self.bodyWeight = latestBodyWeight
        }
        
        if let lastLog = exerciseService.fetchAllExerciseLogs().first,
           let matchingExercise = exercises.first(where: { $0.name == lastLog.exercise }) {
            
            let parentCategory = categories.first(where: { $0.id == matchingExercise.categoryId })
            
            self.selectedMuscle = parentCategory
            self.selectedExercise = matchingExercise
        }
    }
    
    private func updateLatestLogAndAutoPopulate() {
        guard let exercise = selectedExercise else {
            latestExerciseLog = nil
            weight = 0.0
            repetition = 0
            return
        }
        
        let lastLog = exerciseService.fetchLatestExerciseLog(for: exercise.name)
        self.latestExerciseLog = lastLog
        
        if let lastLog {
            self.weight = lastLog.weight
            self.repetition = lastLog.repetition
        } else {
            self.weight = 0.0
            self.repetition = 0
        }
    }
    
    func logBodyWeight() {
        guard bodyWeight > 0 else { return }
        do {
            try bodyWeightService.saveBodyWeight(bodyWeight)
            showToast("Body weight saved!")
        } catch {
            showToast("Failed to save body weight.", isError: true)
        }
    }
    
    func logExerciseSet() {
        guard weight > 0, repetition > 0, let exercise = selectedExercise else { return }
        
        do {
            try exerciseService.saveExerciseLog(
                exercise: exercise.name,
                weight: weight,
                repetition: repetition
            )
            
            self.latestExerciseLog = exerciseService.fetchLatestExerciseLog(for: exercise.name)
            
            showToast("Logged \(exercise.name) (\(weight)kg x \(repetition) reps)")
        } catch {
            showToast("Failed to log set.", isError: true)
        }
    }
    
    func addCategory(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newCategory = MuscleCategory(name: trimmedName)
        do {
            try exerciseService.saveCategory(newCategory)
            self.categories = (try? exerciseService.fetchCategories()) ?? []
            self.selectedMuscle = categories.first(where: { $0.id == newCategory.id })
        } catch {
            print("Failed to save category: \(error)")
        }
    }
    
    func addExercise(name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, let targetCategory = selectedMuscle else { return }
        
        let newExercise = Exercise(categoryId: targetCategory.id, name: trimmedName)
        do {
            try exerciseService.saveExercise(newExercise)
            self.exercises = (try? exerciseService.fetchExercises()) ?? []
            self.selectedExercise = exercises.first(where: { $0.id == newExercise.id })
        } catch {
            print("Failed to save exercise: \(error)")
        }
    }
    
    func showToast(_ message: String, isError: Bool = false) {
        withAnimation(.snappy) {
            self.toastMessage = message
            self.isToastError = isError
        }
        
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation(.snappy) {
                self.toastMessage = nil
            }
        }
    }
}
