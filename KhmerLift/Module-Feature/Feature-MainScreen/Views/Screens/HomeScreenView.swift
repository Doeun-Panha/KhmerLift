//
//  MainScreenView.swift
//  KhmerLift
//
//  Created by Panha on 18/9/26.
//

import SwiftUI

struct HomeScreenModel {
    let title: String
    let streak: Int
    let weight: Double
}

@Observable
final class HomeScreenViewModel {
    var title: String = "KhmerLift"
    var streak: Int = 0
    var bodyWeight: Double = 0.0
    var bodyWeightString: String {
        get {
            bodyWeight == 0 ? "" : String(bodyWeight)
        }
        set {
            if let parsed = Double(newValue) {
                bodyWeight = parsed
            } else if newValue.isEmpty {
                bodyWeight = 0.0
            }
        }
    }
    var selectedMuscle: DropdownItem? = .chest
    var exercise: String = ""
    var weight: Double = 0.0
    var weightString: String {
        get {
            weight == 0 ? "" : String(weight)
        }
        set {
            if let parsed = Double(newValue) {
                weight = parsed
            } else if newValue.isEmpty {
                weight = 0.0
            }
        }
    }
    var repetition: Int = 0
    var repetitionString: String {
        get {
            repetition == 0 ? "" : String(repetition)
        }
        set {
            if let parsed = Int(newValue) {
                repetition = parsed
            } else if newValue.isEmpty {
                repetition = 0
            }
        }
    }
}

struct HomeScreenView: View {
    @State private var viewModel = HomeScreenViewModel()
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(spacing: 5) {
                Text(viewModel.title)
                    .font(.nunito(26, weight: .heavy))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("\(viewModel.streak)")
                    .font(.nunito(20, weight: .medium))
                    .foregroundStyle(.gray)
                
                Image("active-fire-icon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(.gray)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                GlassTextFieldView(
                    title: "Body Weight",
                    placeholder: "kg",
                    text: $viewModel.bodyWeightString,
                    keyboardType: .decimalPad
                )
                
                GlassDropdownView(
                    title: "Target Muscle",
                    placeholder: "Select Muscle",
                    selectedItem: $viewModel.selectedMuscle
                )
                
                GlassTextFieldView(
                    title: "Exercise",
                    placeholder: "Incline Dumbbell Press",
                    text: $viewModel.exercise,
                    keyboardType: .decimalPad
                )
                
                GlassTextFieldView(
                    title: "Weight",
                    placeholder: "kg",
                    text: $viewModel.weightString,
                    keyboardType: .decimalPad
                )
                
                GlassTextFieldView(
                    title: "Repetition",
                    placeholder: "12",
                    text: $viewModel.repetitionString,
                    keyboardType: .decimalPad
                )
                
                Spacer()
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

#Preview {
    struct PreviewContainer: View {
        var body: some View {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                    .containerRelativeFrame([.horizontal, .vertical])
                
                HomeScreenView()
            }
        }
    }
    
    return PreviewContainer()
}
