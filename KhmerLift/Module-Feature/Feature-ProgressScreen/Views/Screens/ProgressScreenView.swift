//
//  ProgressScreenView.swift
//  KhmerLift
//

import SwiftUI

struct ProgressScreenView: View {
    @State private var viewModel = ProgressScreenViewModel()
    @State private var isEditingWeightSummary: Bool = false
    @State private var inputWeightGoal: Double = 0.0

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            headerView
            
            formContentView
        }
        .padding(.horizontal)
        .padding(.leading, 10)
        
        .alert("Set Weight Goal", isPresented: $isEditingWeightSummary) {
            TextField("", value: $inputWeightGoal, format: .number)
                .keyboardType(.decimalPad)
            
            Button("Save") {
                viewModel.saveNewTargetWeight(inputWeightGoal)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your target body weight in kg.")
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 5) {
            Text("Progress")
                .font(.nunito(26, weight: .heavy))
                .foregroundStyle(.white)
            
            Spacer()
        }
        .padding(.top, 30)
    }
    
    private var formContentView: some View {
        VStack(spacing: 16) {
            WeightSummaryCardView(
                viewModel: viewModel,
                onEditTap: {
                    inputWeightGoal = viewModel.summary.targetWeight
                    isEditingWeightSummary = true
                }
            )
            
            Spacer()
        }
        .onAppear {
            viewModel.loadSummary()
        }
    }
}
