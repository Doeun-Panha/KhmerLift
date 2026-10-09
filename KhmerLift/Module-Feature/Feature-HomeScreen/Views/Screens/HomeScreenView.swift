//
//  HomeScreenView.swift
//  KhmerLift
//
//  Created by Panha on 21/9/26.
//

import SwiftUI

enum FormField: Hashable {
    case bodyWeight
    case weight
    case repetition
}

struct HomeScreenView: View {
    @State private var viewModel = HomeScreenViewModel()
    @FocusState private var focusedField: FormField?

    var body: some View {
        @Bindable var viewModel = viewModel
        
        VStack(alignment: .center, spacing: 16) {
            headerView
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    formContentView
                        .padding(.bottom, 120)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: focusedField) { _, newField in
                    scrollToFocusedField(newField, using: proxy)
                }
            }
        }
        .padding(.horizontal)
        .padding(.leading, 10)
        .onSubmit(advanceFocus)
        
        .alert("Add New Target Muscle", isPresented: $viewModel.isAddingCategory) {
            TextField("e.g. Shoulders, Arms", text: $viewModel.newCategoryName)
            Button("Add") {
                viewModel.commitNewCategory()
            }
            Button("Cancel", role: .cancel) {
                viewModel.cancelCategoryInput()
            }
        } message: {
            Text("Enter a name for the new muscle group.")
        }
        
        .alert("Add New Exercise", isPresented: $viewModel.isAddingExercise) {
            TextField("e.g. Lateral Raise, Bicep Curl", text: $viewModel.newExerciseName)
            Button("Add") {
                viewModel.commitNewExercise()
            }
            Button("Cancel", role: .cancel) {
                viewModel.cancelExerciseInput()
            }
        } message: {
            Text(viewModel.addExerciseAlertMessage)
        }
        
        .toast(viewModel.toast)
    }
    
    private var headerView: some View {
        HStack(spacing: 5) {
            Text(viewModel.title)
                .font(.nunito(26, weight: .heavy))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text("\(viewModel.streakCount)")
                .font(.nunito(20, weight: .medium))
                .foregroundStyle(viewModel.isLoggedToday ? .orange : .gray)
            
            Image(viewModel.isLoggedToday ? "active-fire-icon" : "inactive-fire-icon")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
        }
        .padding(.top, 30)
    }
    
    private var formContentView: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                
                Text("DAILY WEIGHT")
                    .font(.nunito(18, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(1)
                
                Spacer()
            }
            
            GlassTextFieldView(
                title: "Body Weight",
                placeholder: "20kg+",
                text: $viewModel.bodyWeightString,
                keyboardType: .decimalPad,
                maxLength: 5,
                allowedRange: 20.0...300.0,
                onExceedLimit: {
                    viewModel.showToast(.warning("Maximum 5 characters allowed."))
                },
                onOutOfRange: {
                    viewModel.showToast(.error("Body weight must be between 20kg and 300kg."))
//                    triggerErrorHaptic()
                }
            )
            .focused($focusedField, equals: .bodyWeight)
            .id(FormField.bodyWeight)
            
            Button {
                focusedField = nil
                viewModel.logBodyWeight()
//                triggerSuccessHaptic()
            } label: {
                HStack {
                    Text("Log Body Weight")
                        .font(.nunito(15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12.5)
                        .contentShape(Rectangle())
                }
                .background(Color.blue.opacity(0.15))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isBodyWeightValid)
            .glassEffect(.clear, in: Capsule())
            
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)
                .padding(.vertical, 8)
            
            HStack {
                Spacer()
                
                Text("WORKOUT LOG")
                    .font(.nunito(18, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(1)
                
                Spacer()
            }
            
            GlassDropdownView(
                title: "Target Muscle",
                placeholder: "Select Muscle",
                selection: $viewModel.selectedMuscle,
                items: viewModel.categories,
                onAddNew: {
                    viewModel.isAddingCategory = true
                }
            )
            
            GlassDropdownView(
                title: "Exercise",
                placeholder: viewModel.exercisePlaceholderText,
                selection: $viewModel.selectedExercise,
                items: viewModel.filteredExercises,
                isDisabled: viewModel.isExerciseDropdownDisabled,
                onAddNew: {
                    viewModel.isAddingExercise = true
                }
            )
            
            if let previousSetSummary = viewModel.previousSetSummary {
                Text(previousSetSummary)
                    .font(.nunito(14, weight: .semibold))
                    .foregroundStyle(.white)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            GlassTextFieldView(
                title: "Weight",
                placeholder: "kg",
                text: $viewModel.weightString,
                keyboardType: .decimalPad,
                maxLength: 5,
                allowedRange: 0.0...500.0,
                onExceedLimit: {
                    viewModel.showToast(.warning("Maximum 3 characters allowed."))
                },
                onOutOfRange: {
                    viewModel.showToast(.error("Weight cannot exceed 500kg."))
                }
            )
            .focused($focusedField, equals: .weight)
            .id(FormField.weight)
            
            GlassTextFieldView(
                title: "Repetition",
                placeholder: "0",
                text: $viewModel.repetitionString,
                keyboardType: .numberPad,
                maxLength: 3,
                allowedRange: 1.0...200.0,
                onExceedLimit: {
                    viewModel.showToast(.warning("Maximum 3 digits allowed."))
                },
                onOutOfRange: {
                    viewModel.showToast(.error("Reps must be between 1 and 200."))
                }
            )
            .focused($focusedField, equals: .repetition)
            .id(FormField.repetition)
            
            Button {
                focusedField = nil
                viewModel.logExerciseSet()
//                triggerSuccessHaptic()
            } label: {
                HStack {
                    Text("Log Set")
                        .font(.nunito(15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12.5)
                        .contentShape(Rectangle())
                }
                .background(Color.blue.opacity(0.15))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isExerciseSetValid)
            .glassEffect(.clear, in: Capsule())
        }
    }
    
    private func advanceFocus() {
        switch focusedField {
        case .bodyWeight:
            focusedField = nil
            
        case .weight:
            focusedField = .repetition
            
        case .repetition, .none:
            focusedField = nil
        }
    }
    
    private func scrollToFocusedField(_ field: FormField?, using proxy: ScrollViewProxy) {
        guard let field else { return }
        
        Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            withAnimation(.easeInOut(duration: 0.25)) {
                proxy.scrollTo(field, anchor: .center)
            }
        }
    }
}
