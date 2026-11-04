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
    private let streakService: StreakServiceProtocol
    private let waterService: WaterServiceProtocol
    
    var categories: [MuscleCategory] = []
    var exercises: [Exercise] = []
    private(set) var latestExerciseLog: ExerciseLog?
    var totalWaterToday: Double = 0.0
    
    var toast: ToastConfig? = nil
    private var toastTask: Task<Void, Never>?
    
    let title: String = "KhmerLift"
    var streakCount: Int = 0
    var isLoggedToday: Bool = false
    
    var bodyWeight: Double = 0.0
    var weight: Double = 0.0
    var repetition: Int = 0
    var waterIntake: Double = 0.0
    var waterGoal: Double = 3000.0
    
    var bodyWeightString: String {
        get { bodyWeight == 0 ? "" : String(bodyWeight) }
        set {
            if let parsed = Double(newValue) { bodyWeight = parsed }
            else if newValue.isEmpty { bodyWeight = 0.0 }
        }
    }
    var weightString: String {
        get { weight == 0 ? "" : String(weight) }
        set {
            if let parsed = Double(newValue) { weight = parsed }
            else if newValue.isEmpty { weight = 0.0 }
        }
    }
    var repetitionString: String {
        get { repetition == 0 ? "" : String(repetition) }
        set {
            if let parsed = Int(newValue) { repetition = parsed }
            else if newValue.isEmpty { repetition = 0 }
        }
    }
    var waterIntakeString: String {
        get { waterIntake == 0 ? "" : String(waterIntake) }
        set {
            if let parsed = Double(newValue) { waterIntake = parsed }
            else if newValue.isEmpty { waterIntake = 0.0 }
        }
    }

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
    var selectedExercise: Exercise? {
        didSet {
            updateLatestLogAndAutoPopulate()
        }
    }
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
    
    var isAddingCategory: Bool = false
    var newCategoryNameString: String = ""
    var isAddingExercise: Bool = false
    var newExerciseNameString: String = ""
    var isEditingWaterGoal: Bool = false
    var newWaterGoalString: String = ""
    
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
    
    var formattedTotalWaterToday: String {
        return "\(Int(totalWaterToday)) ml"
    }
    
    init(
        bodyWeightService: BodyWeightServiceProtocol? = nil,
        exerciseService: ExerciseServiceProtocol? = nil,
        streakService: StreakServiceProtocol? = nil,
        waterService: WaterServiceProtocol? = nil
    ) {
        self.bodyWeightService = bodyWeightService ?? BodyWeightService()
        self.exerciseService = exerciseService ?? ExerciseService()
        self.streakService = streakService ?? StreakService()
        self.waterService = waterService ?? WaterService()
        
        loadInitialDataAndPreFill()
    }
}

extension HomeScreenViewModel {
    enum ValidationLimits {
        static let bodyWeight: ClosedRange<Double> = 20.0...300.0
        static let exerciseWeight: ClosedRange<Double> = 1.0...500.0
        static let repetition: ClosedRange<Int> = 1...200
        static let waterIntake: ClosedRange<Double> = 1.0...5000.0
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
    
    var isWaterIntakeValid: Bool {
        ValidationLimits.waterIntake.contains(waterIntake)
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
        if waterIntake > 0 && !ValidationLimits.waterIntake.contains(waterIntake) {
            return "Water intake must between >0ml and 5000ml."
        }
        return nil
    }
}

extension HomeScreenViewModel {
    func showToast(_ config: ToastConfig) {
        toastTask?.cancel()
        
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
    private func loadInitialDataAndPreFill() {
        self.categories = (try? exerciseService.fetchCategories()) ?? []
        self.exercises = (try? exerciseService.fetchExercises()) ?? []
        
        updateStreak()
        
        if let latestBodyWeight = bodyWeightService.fetchLatestBodyWeight() {
            self.bodyWeight = latestBodyWeight
        }
        
        self.totalWaterToday = waterService.fetchTotalWaterToday()
        self.waterGoal = waterService.fetchWaterGoal()
        
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
    
    private func updateStreak() {
        let status = streakService.fetchStreakStatus()
        self.streakCount = status.count
        self.isLoggedToday = status.isLoggedToday
    }
}

extension HomeScreenViewModel {
    func logBodyWeight() {
        guard isBodyWeightValid else { return }
        
        do {
            try bodyWeightService.saveBodyWeight(bodyWeight)
            updateStreak()
            showToast(.success("Body weight saved!"))
        } catch {
            showToast(.error("Failed to save body weight."))
        }
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
            updateStreak()
            
            let formattedWeight = weight.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", weight)
                : String(format: "%.1f", weight)
            
            showToast(.success("Logged \(exercise.name) (\(formattedWeight) kg × \(repetition) reps)"))
        } catch {
            showToast(.error("Failed to log set."))
        }
    }
    
    func logWaterIntake() {
        guard isWaterIntakeValid else { return }
        
        do {
            try waterService.saveWaterLog(waterIntake)
            totalWaterToday = waterService.fetchTotalWaterToday()
            updateStreak()
            
            let loggedAmount = Int(waterIntake)
            showToast(.success("Logged \(loggedAmount)ml of water!"))
            
            waterIntake = 0.0
        } catch {
            showToast(.error("Failed to log water intake."))
        }
    }
}

extension HomeScreenViewModel {
    func commitNewCategory() {
        let trimmedName = newCategoryNameString.trimmingCharacters(in: .whitespacesAndNewlines)
        defer { newCategoryNameString = "" }
        guard !trimmedName.isEmpty else { return }
        
        let newCategory = MuscleCategory(name: trimmedName)
        do {
            try exerciseService.saveCategory(newCategory)
            self.categories = (try? exerciseService.fetchCategories()) ?? []
            self.selectedMuscle = categories.first(where: { $0.id == newCategory.id })
        } catch {
            showToast(.error("Failed to save target muscle."))
        }
    }
    
    func commitNewExercise() {
        let trimmedName = newExerciseNameString.trimmingCharacters(in: .whitespacesAndNewlines)
        defer { newExerciseNameString = "" }
        guard !trimmedName.isEmpty, let targetCategory = selectedMuscle else { return }
        
        let newExercise = Exercise(categoryId: targetCategory.id, name: trimmedName)
        do {
            try exerciseService.saveExercise(newExercise)
            self.exercises = (try? exerciseService.fetchExercises()) ?? []
            self.selectedExercise = exercises.first(where: { $0.id == newExercise.id })
        } catch {
            showToast(.error("Failed to save exercise."))
        }
    }
    
    func commitNewWaterGoal() {
        let trimmed = newWaterGoalString.trimmingCharacters(in: .whitespacesAndNewlines)
        defer { newWaterGoalString = "" }
        
        guard let parsedGoal = Double(trimmed), parsedGoal > 0 else {
            showToast(.error("Invalid water goal."))
            return
        }
        
        waterGoal = parsedGoal
        waterService.saveWaterGoal(waterGoal)
        
        showToast(.success("Water goal updated to \(Int(waterGoal))ml!"))
    }
    
    func cancelCategoryInput() {
        newCategoryNameString = ""
    }
    
    func cancelExerciseInput() {
        newExerciseNameString = ""
    }
    
    func cancelWaterGoalInput() {
        newWaterGoalString = ""
    }
}

extension HomeScreenViewModel {
    func handleBodyWeightExceedLimit() {
        showToast(.warning("Maximum 5 characters allowed."))
    }
    
    func handleWeightExceedLimit() {
        showToast(.warning("Maximum 5 characters allowed."))
    }
    
    func handleRepetitionExceedLimit() {
        showToast(.warning("Maximum 3 digits allowed."))
    }
    
    func handleWaterIntakeExceedLimit() {
        showToast(.warning("Maximum 5 characters allowed."))
    }
    
    func handleBodyWeightOutOfRange() {
        showToast(.warning("Body weight must be between 20kg and 300kg."))
    }
    
    func handleWeightOutOfRange() {
        showToast(.warning("Weight must be between 1kg and 500kg."))
    }
    
    func handleRepetitionOutOfRange() {
        showToast(.warning("Reps must be between 1 and 200."))
    }
    
    func handleWaterIntakeOutOfRange() {
        showToast(.warning("Water intake must be between 1ml and 5000ml."))
    }
}

extension HomeScreenViewModel {
    var bodyWeightTextFieldConfig: GlassTextFieldConfig {
        GlassTextFieldConfig(
            title: "Body Weight",
            placeholder: "20kg+",
            keyboardType: .decimalPad,
            maxLength: 5,
            allowedRange: ValidationLimits.bodyWeight,
            onExceedLimit: { self.handleBodyWeightExceedLimit() },
            onOutOfRange: { self.handleBodyWeightOutOfRange() }
        )
    }
    
    var weightTextFieldConfig: GlassTextFieldConfig {
        GlassTextFieldConfig(
            title: "Weight",
            placeholder: "kg",
            keyboardType: .decimalPad,
            maxLength: 5,
            allowedRange: ValidationLimits.exerciseWeight,
            onExceedLimit: { self.handleWeightExceedLimit() },
            onOutOfRange: { self.handleWeightOutOfRange() }
        )
    }
    
    var repetitionTextFieldConfig: GlassTextFieldConfig {
        GlassTextFieldConfig(
            title: "Repetition",
            placeholder: "0",
            keyboardType: .numberPad,
            maxLength: 3,
            allowedRange: 1.0...200.0,
            onExceedLimit: { self.handleRepetitionExceedLimit() },
            onOutOfRange: { self.handleRepetitionOutOfRange() }
        )
    }
    
    var waterIntakeTextFieldConfig: GlassTextFieldConfig {
        GlassTextFieldConfig(
            title: "Water Intake",
            placeholder: "ml",
            keyboardType: .decimalPad,
            maxLength: 6,
            allowedRange: ValidationLimits.waterIntake,
            onExceedLimit: { self.handleWaterIntakeExceedLimit() },
            onOutOfRange: { self.handleWaterIntakeOutOfRange() }
        )
    }
}

extension HomeScreenViewModel {
    var targetMuscleDropdownConfig: GlassDropdownConfig<MuscleCategory> {
        GlassDropdownConfig(
            title: "Target Muscle",
            placeholder: "Select Muscle",
            items: categories,
            isDisabled: false,
            onAddNew: { [weak self] in
                self?.isAddingCategory = true
            }
        )
    }
    
    var exerciseDropdownConfig: GlassDropdownConfig<Exercise> {
        GlassDropdownConfig(
            title: "Exercise",
            placeholder: exercisePlaceholderText,
            items: filteredExercises,
            isDisabled: isExerciseDropdownDisabled,
            onAddNew: { [weak self] in
                self?.isAddingExercise = true
            }
        )
    }
}

extension HomeScreenViewModel {
    func handleQuickButton1() {
        waterIntake = 250.0
    }
    
    func handleQuickButton2() {
        waterIntake = 500.0
    }
    
    func handleQuickButton3() {
        waterIntake = 1000.0
    }
}
