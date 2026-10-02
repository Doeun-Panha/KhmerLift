//
//  WeightSummaryCardView.swift
//  KhmerLift
//

import SwiftUI

struct WeightSummaryCardView: View {
    let viewModel: ProgressScreenViewModel
    let onEditTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Weight")
                    .font(.nunito(22, weight: .semibold))
                    .foregroundStyle(.white)
                    .tracking(1)
                
                Spacer()
                
                Button(action: onEditTap) {
                    Image(systemName: "square.and.pencil")
                        .font(.nunito(22, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.formattedCurrentTitle)
                            .font(.nunito(16, weight: .light))
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)
                        
                        Text(viewModel.formattedCurrentWeight)
                            .font(.nunito(22, weight: .semibold))
                            .foregroundStyle(.white)
                            .tracking(1)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Goal")
                            .font(.nunito(16, weight: .light))
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)
                        
                        Text(viewModel.formattedTargetWeight)
                            .font(.nunito(22, weight: .semibold))
                            .foregroundStyle(.white)
                            .tracking(1)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.formattedChangeTitle)
                            .font(.nunito(16, weight: .light))
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)
                        
                        Text(viewModel.formattedMonthlyChange)
                            .font(.nunito(22, weight: .semibold))
                            .foregroundStyle(.white)
                            .tracking(1)
                    }
                }
                
                Spacer()
                
                Text("Graph")
                    .font(.nunito(22, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.black.opacity(0.10))
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )
        )
    }
}
