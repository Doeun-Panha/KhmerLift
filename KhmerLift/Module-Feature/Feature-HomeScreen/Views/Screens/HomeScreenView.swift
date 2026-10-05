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
    @State private var displayInfo: DisplayLayoutInfo?
    
    @State private var isAddingCategory: Bool = false
    @State private var newCategoryName: String = ""
    
    @State private var isAddingExercise: Bool = false
    @State private var newExerciseName: String = ""
    
    @FocusState private var focusedField: FormField?

    
    var body: some View {
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
        
        .alert("Add New Target Muscle", isPresented: $isAddingCategory) {
            TextField("e.g. Shoulders, Arms", text: $newCategoryName)
            Button("Add") {
                viewModel.addCategory(name: newCategoryName)
                newCategoryName = ""
            }
            Button("Cancel", role: .cancel) {
                newCategoryName = ""
            }
        } message: {
            Text("Enter a name for the new muscle group.")
        }
        
        .alert("Add New Exercise", isPresented: $isAddingExercise) {
            TextField("e.g. Lateral Raise, Bicep Curl", text: $newExerciseName)
            Button("Add") {
                viewModel.addExercise(name: newExerciseName)
                newExerciseName = ""
            }
            Button("Cancel", role: .cancel) {
                newExerciseName = ""
            }
        } message: {
            if let targetCategory = viewModel.selectedMuscle {
                Text("Adding new exercise under '\(targetCategory.name)'.")
            }
        }
        
        .overlay(alignment: .top) {
            if let toastMessage = viewModel.toastMessage {
                ToastBannerView(
                    message: toastMessage,
                    isError: viewModel.isToastError
                )
                .padding(.top, 10)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.snappy, value: viewModel.toastMessage)
    }
    
    private var headerView: some View {
        HStack(spacing: 5) {
            Text("KhmerLift")
                .font(.nunito(26, weight: .heavy))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text("0")
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
            .submitLabel(.done)
            
            Button(action: {
                focusedField = nil
                viewModel.logBodyWeight()
                dismissKeyboard()
                triggerHaptic()
            }) {
                Text("Log Body Weight")
                    .font(.nunito(15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12.5)
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
                    isAddingCategory = true
                }
            )
            
            GlassDropdownView(
                title: "Exercise",
                placeholder: viewModel.selectedMuscle == nil ? "Select Muscle First" : "Select Exercise",
                selection: $viewModel.selectedExercise,
                items: viewModel.filteredExercises,
                isDisabled: viewModel.selectedMuscle == nil,
                onAddNew: {
                    isAddingExercise = true
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
            .submitLabel(.next)
            
            GlassTextFieldView(
                title: "Repetition",
                placeholder: "0",
                text: $viewModel.repetitionString,
                keyboardType: .numberPad
            )
            .focused($focusedField, equals: .repetition)
            .id(FormField.repetition)
            .submitLabel(.done)
            
            Button(action: {
                focusedField = nil
                viewModel.logExerciseSet()
                dismissKeyboard()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.25)) {
                proxy.scrollTo(field, anchor: .center)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HomeScreenView()
    }
}
