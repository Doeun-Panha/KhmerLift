//
//  HomeScreenViewModel.swift
//  KhmerLift
//
//  Created by Panha on 28/9/26.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class HomeScreenViewModel {
    private let bodyWeightService: BodyWeightServiceProtocol
    private let exerciseService: ExerciseServiceProtocol
    
    var title: String = "KhmerLift"
    var streakCount: Int = 0
    
    var bodyWeight: Double = 0.0
    var bodyWeightString: String {
        get { bodyWeight == 0 ? "" : String(bodyWeight) }
        set {
            if let parsed = Double(newValue) { bodyWeight = parsed }
            else if newValue.isEmpty { bodyWeight = 0.0 }
        }
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
    
    var isAddingCategory: Bool = false
    var newCategoryName: String = ""
    
    var exercises: [Exercise] = []
    var selectedExercise: Exercise? {
        didSet {
            updateLatestLogAndAutoPopulate()
        }
    }
    
    var isAddingExercise: Bool = false
    var newExerciseName: String = ""
    
    private(set) var latestExerciseLog: ExerciseLog?
    
    var filteredExercises: [Exercise] {
        guard let selectedMuscle else { return [] }
        return exercises.filter { $0.categoryId == selectedMuscle.id }
    }
    
    var isExerciseDropdownDisabled: Bool {
        selectedMuscle == nil
    }
    
    var exercisePlaceholderText: String {
        selectedMuscle == nil ? "Select Muscle First" : "Select Exercise"
    }
    
    var addExerciseAlertMessage: String {
        guard let selectedMuscle else { return "" }
        return "Adding new exercise under '\(selectedMuscle.name)'."
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
    
    var toast: ToastConfig? = nil
    private var toastTask: Task<Void, Never>?
    
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
        guard isBodyWeightValid else { return }
        
        do {
            try bodyWeightService.saveBodyWeight(bodyWeight)
            showToast(
                message: "Body weight saved!",
                icon: "checkmark.circle.fill",
                tintColor: .green
            )
        } catch {
            showToast(
                message: "Failed to save body weight.",
                icon: "exclamationmark.triangle.fill",
                tintColor: .red
            )
        }
    }
    
    func commitNewCategory() {
        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        defer { newCategoryName = "" }
        guard !trimmedName.isEmpty else { return }
        
        let newCategory = MuscleCategory(name: trimmedName)
        do {
            try exerciseService.saveCategory(newCategory)
            self.categories = (try? exerciseService.fetchCategories()) ?? []
            self.selectedMuscle = categories.first(where: { $0.id == newCategory.id })
        } catch {
            showToast(
                message: "Failed to save target muscle.",
                icon: "exclamationmark.triangle.fill",
                tintColor: .red
            )
        }
    }
    
    func cancelCategoryInput() {
        newCategoryName = ""
    }
    
    func commitNewExercise() {
        let trimmedName = newExerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        defer { newExerciseName = "" }
        guard !trimmedName.isEmpty, let targetCategory = selectedMuscle else { return }
        
        let newExercise = Exercise(categoryId: targetCategory.id, name: trimmedName)
        do {
            try exerciseService.saveExercise(newExercise)
            self.exercises = (try? exerciseService.fetchExercises()) ?? []
            self.selectedExercise = exercises.first(where: { $0.id == newExercise.id })
        } catch {
            showToast(
                message: "Failed to save exercise.",
                icon: "exclamationmark.triangle.fill",
                tintColor: .red
            )
        }
    }
    
    func cancelExerciseInput() {
        newExerciseName = ""
    }
    
    func logExerciseSet() {
        guard isExerciseSetValid, let exercise = selectedExercise else { return }
        
        do {
            try exerciseService.saveExerciseLog(
                exercise: exercise.name,
                weight: weight,
                repetition: repetition
            )
            
            self.latestExerciseLog = exerciseService.fetchLatestExerciseLog(for: exercise.name)
            
            showToast(
                message: "Logged \(exercise.name) (\(weight)kg x \(repetition) reps)",
                icon: "checkmark.circle.fill",
                tintColor: .green
            )
        } catch {
            showToast(
                message: "Failed to log set.",
                icon: "exclamationmark.triangle.fill",
                tintColor: .red
            )
        }
    }
    
    func showToast(
        message: String,
        icon: String? = "info.circle.fill",
        tintColor: Color = .blue
    ) {
        toastTask?.cancel()
        
        let config = ToastConfig(message: message, icon: icon, tintColor: tintColor)
        self.toast = config
        
        toastTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            
            if self.toast == config {
                self.toast = nil
            }
        }
    }
}

extension HomeScreenViewModel {
    enum ValidationLimits {
        static let bodyWeight: ClosedRange<Double> = 20.0...300.0
        static let exerciseWeight: ClosedRange<Double> = 0.0...500.0
        static let repetition: ClosedRange<Int> = 1...200
    }
    
    var isBodyWeightValid: Bool {
        ValidationLimits.bodyWeight.contains(bodyWeight)
    }
    
    var isExerciseSetValid: Bool {
        guard selectedExercise != nil else { return false }
        
        let isValidWeight = ValidationLimits.exerciseWeight.contains(weight)
        let isValidReps = ValidationLimits.repetition.contains(repetition)
        
        return isValidWeight && isValidReps
    }
    
    var validationErrorMessage: String? {
        if bodyWeight > 0 && !ValidationLimits.bodyWeight.contains(bodyWeight) {
            return "Body weight must be between 20 kg and 250 kg."
        }
        if weight > ValidationLimits.exerciseWeight.upperBound {
            return "Weight cannot exceed 500 kg."
        }
        if repetition > ValidationLimits.repetition.upperBound {
            return "Reps cannot exceed 100."
        }
        return nil
    }
}
