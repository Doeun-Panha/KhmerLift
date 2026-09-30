//
//  HomeScreenViewModel.swift
//  KhmerLift
//
//  Created by Panha on 28/9/26.
//

import SwiftUI

@Observable
final class HomeScreenViewModel {
    private let homeScreenService: HomeScreenServiceProtocol
    
    var title: String = "KhmerLift"
    
    // MARK: - Body Weight
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
    
    // MARK: - Categories & Exercises
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
    
    // MARK: - Weight & Repetition
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
    
    // MARK: - Toast / Feedback State
    var toastMessage: String?
    var isToastError: Bool = false
    
    // MARK: - Initialization
    @MainActor
    init(homeScreenService: HomeScreenServiceProtocol? = nil) {
        let service = homeScreenService ?? HomeScreenService()
        self.homeScreenService = service
        
        loadInitialDataAndPreFill()
    }
    
    // MARK: - Private Helpers
    @MainActor
    private func loadInitialDataAndPreFill() {
        self.categories = (try? homeScreenService.fetchCategories()) ?? []
        self.exercises = (try? homeScreenService.fetchExercises()) ?? []
        
        if let latestBodyWeight = homeScreenService.fetchLatestBodyWeight() {
            self.bodyWeight = latestBodyWeight
        }
        
        if let lastLog = homeScreenService.fetchAllExerciseLogs().first,
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
        
        let lastLog = homeScreenService.fetchLatestExerciseLog(for: exercise.name)
        self.latestExerciseLog = lastLog
        
        if let lastLog {
            self.weight = lastLog.weight
            self.repetition = lastLog.repetition
        } else {
            self.weight = 0.0
            self.repetition = 0
        }
    }
    
    // MARK: - User Actions
    func logBodyWeight() {
        guard bodyWeight > 0 else { return }
        do {
            try homeScreenService.saveBodyWeight(bodyWeight)
            showToast("Body weight saved!")
        } catch {
            showToast("Failed to save body weight.", isError: true)
        }
    }
    
    func logExerciseSet() {
        guard weight > 0, repetition > 0, let exercise = selectedExercise else { return }
        
        do {
            try homeScreenService.saveExerciseLog(
                exercise: exercise.name,
                weight: weight,
                repetition: repetition
            )
            
            // Refresh latest log for summary view
            self.latestExerciseLog = homeScreenService.fetchLatestExerciseLog(for: exercise.name)
            
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
            try homeScreenService.saveCategory(newCategory)
            self.categories = (try? homeScreenService.fetchCategories()) ?? []
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
            try homeScreenService.saveExercise(newExercise)
            self.exercises = (try? homeScreenService.fetchExercises()) ?? []
            self.selectedExercise = exercises.first(where: { $0.id == newExercise.id })
        } catch {
            print("Failed to save exercise: \(error)")
        }
    }
    
    @MainActor
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
