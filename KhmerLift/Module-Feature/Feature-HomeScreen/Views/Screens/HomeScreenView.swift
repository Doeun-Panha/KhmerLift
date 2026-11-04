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
    case waterIntake
}

struct HomeScreenView: View {
    @State private var viewModel = HomeScreenViewModel()
    @FocusState private var focusedField: FormField?

    var body: some View {
        @Bindable var viewModel = viewModel

        containerView
    }
}

extension HomeScreenView {
    private var containerView: some View {
        VStack(alignment: .center, spacing: 16) {
            headerView
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    contentView
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: focusedField) { _, newField in
                    scrollToFocusedField(newField, using: proxy)
                }
            }
        }
        .padding(.horizontal)
        .padding(.leading, 10)
                
        .alert("Add New Target Muscle", isPresented: $viewModel.isAddingCategory) {
            TextField("e.g. Shoulders, Arms", text: $viewModel.newCategoryNameString)
            Button("Add") { viewModel.commitNewCategory() }
            Button("Cancel", role: .cancel) { viewModel.cancelCategoryInput() }
        } message: {
            Text("Enter a name for the new muscle group.")
        }
        
        .alert("Add New Exercise", isPresented: $viewModel.isAddingExercise) {
            TextField("e.g. Lateral Raise, Bicep Curl", text: $viewModel.newExerciseNameString)
            Button("Add") { viewModel.commitNewExercise() }
            Button("Cancel", role: .cancel) { viewModel.cancelExerciseInput() }
        } message: {
            Text(viewModel.addExerciseAlertMessage)
        }
        
        .alert("Set Water Goal", isPresented: $viewModel.isEditingWaterGoal) {
            TextField("e.g. 3000", text: $viewModel.newWaterGoalString)
                .keyboardType(.numberPad)
            Button("Save") { viewModel.commitNewWaterGoal() }
            Button("Cancel", role: .cancel) { viewModel.cancelWaterGoalInput() }
        } message: {
            Text("Enter your daily target water intake in ml.")
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
                .foregroundStyle(viewModel.isLoggedToday ? .orange : .white.opacity(0.75))
            
            if viewModel.isLoggedToday {
                Image("active-fire-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
            } else {
                Image("inactive-fire-icon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
        .padding(.top, 30)
    }
    
    private var contentView: some View {
        VStack(spacing: 16) {
            bodyWeightSectionView
            workoutSectionView
            waterIntakeSectionView
        }
        .padding(.bottom, 120)
    }
    
    private var bodyWeightSectionView: some View {
        VStack(spacing: 16) {
            SectionHeaderView(title: "Daily Weight")
            
            GlassTextFieldView(
                config: viewModel.bodyWeightTextFieldConfig,
                text: $viewModel.bodyWeightString
            )
            .focused($focusedField, equals: .bodyWeight)
            .id(FormField.bodyWeight)
            
            GlassLogButton(
                title: "Log Body Weight",
                isDisabled: !viewModel.isBodyWeightValid
            ) {
                focusedField = nil
                viewModel.logBodyWeight()
            }
            
            LineDividerView()
        }
        .padding(0)
    }
    
    private var workoutSectionView: some View {
        VStack(spacing: 16) {
            SectionHeaderView(title: "Workout Log")
            
            GlassDropdownView(
                config: viewModel.targetMuscleDropdownConfig,
                selection: $viewModel.selectedMuscle
            )
            
            GlassDropdownView(
                config: viewModel.exerciseDropdownConfig,
                selection: $viewModel.selectedExercise
            )
            
            if let previousSetSummary = viewModel.previousSetSummary {
                Text(previousSetSummary)
                    .font(.nunito(14, weight: .semibold))
                    .foregroundStyle(.white)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            GlassTextFieldView(
                config: viewModel.weightTextFieldConfig,
                text: $viewModel.weightString
            )
            .focused($focusedField, equals: .weight)
            .id(FormField.weight)
            
            GlassTextFieldView(
                config: viewModel.repetitionTextFieldConfig,
                text: $viewModel.repetitionString
            )
            .focused($focusedField, equals: .repetition)
            .id(FormField.repetition)
            
            GlassLogButton(
                title: "Log Set",
                isDisabled: !viewModel.isExerciseSetValid
            ) {
                focusedField = nil
                viewModel.logExerciseSet()
            }
            
            LineDividerView()
        }
        .padding(0)
    }
    
    private var waterIntakeSectionView: some View {
        VStack(spacing: 16){
            SectionHeaderView(title: "Daily Water")
            
            WaterProgressBarView(
                current: viewModel.totalWaterToday,
                goal: viewModel.waterGoal,
                onTap: {
                    focusedField = .waterIntake
                },
                onEdit: {
                    viewModel.newWaterGoalString = String(Int(viewModel.waterGoal))
                    viewModel.isEditingWaterGoal = true
                }
            )
            
            GlassTextFieldView(
                config: viewModel.waterIntakeTextFieldConfig,
                text: $viewModel.waterIntakeString
            )
            .focused($focusedField, equals: .waterIntake)
            .id(FormField.waterIntake)
            
            HStack {
                InstantBouncyButton(action: viewModel.handleQuickButton1) {
                    Text("250ml")
                        .font(.nunito(15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12.5)
                        .clipShape(Capsule())
                        .glassEffect(.clear, in: Capsule())
                }
                
                Spacer()
                
                InstantBouncyButton(action: viewModel.handleQuickButton2) {
                    Text("500ml")
                        .font(.nunito(15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12.5)
                        .clipShape(Capsule())
                        .glassEffect(.clear, in: Capsule())
                }
                
                Spacer()
                
                InstantBouncyButton(action: viewModel.handleQuickButton3) {
                    Text("1000ml")
                        .font(.nunito(15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12.5)
                        .clipShape(Capsule())
                        .glassEffect(.clear, in: Capsule())
                }
            }
            
            GlassLogButton(
                title: "Log Water",
                isDisabled: !viewModel.isWaterIntakeValid
            ) {
                focusedField = nil
                viewModel.logWaterIntake()
            }
        }
        .padding(0)
    }
}

extension HomeScreenView {
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

struct InstantBouncyButton<Content: View>: View {
    let action: () -> Void
    @ViewBuilder let content: () -> Content
    
    @State private var isPressed = false
    
    var body: some View {
        content()
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: isPressed)
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
    }
}

struct WaterProgressBarView: View {
    let current: Double
    let goal: Double
    let onTap: () -> Void
    let onEdit: () -> Void
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .leading) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geometry.size.width * CGFloat(progress), 0))
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
                        
                        HStack {
                            Spacer()
                            Text("\(Int(current)) / \(Int(goal)) ml")
                                .font(.nunito(12, weight: .bold))
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            Spacer()
                        }
                    }
                }
            }
            .frame(height: 36)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onTapGesture(perform: onTap)
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .glassEffect(.clear, in: Circle())
        }
    }
}
