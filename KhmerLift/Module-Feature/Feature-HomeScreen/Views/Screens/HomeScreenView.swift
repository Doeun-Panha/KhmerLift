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
                .foregroundStyle(.gray)
            
            Image("active-fire-icon")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundStyle(.gray)
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
                placeholder: "kg",
                text: $viewModel.bodyWeightString,
                keyboardType: .decimalPad
            )
            .focused($focusedField, equals: .bodyWeight)
            .id(FormField.bodyWeight)
            
            Button(action: {
                focusedField = nil
                viewModel.logBodyWeight()
                triggerHaptic()
            }) {
                Text("Log Body Weight")
                    .font(.nunito(15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12.5)
                    .contentShape(Rectangle())
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isBodyWeightValid)
            
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
                keyboardType: .decimalPad
            )
            .focused($focusedField, equals: .weight)
            .id(FormField.weight)
            
            GlassTextFieldView(
                title: "Repetition",
                placeholder: "0",
                text: $viewModel.repetitionString,
                keyboardType: .numberPad
            )
            .focused($focusedField, equals: .repetition)
            .id(FormField.repetition)
            
            Button(action: {
                focusedField = nil
                viewModel.logExerciseSet()
                triggerHaptic()
            }) {
                Text("Log Set")
                    .font(.nunito(15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12.5)
                    .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isExerciseSetValid)
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
