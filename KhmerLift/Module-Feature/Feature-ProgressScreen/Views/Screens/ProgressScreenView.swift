//
//  ProgressScreenView.swift
//  KhmerLift
//
//  Created by Panha on 30/9/26.
//

import SwiftUI

struct ProgressScreenView: View {
    @State private var viewModel = ProgressScreenViewModel()
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            headerView
            
            formContentView
        }
        .padding(.horizontal)
        .padding(.leading, 10)
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
            HStack {
                Spacer()
                Text("DAILY WEIGHT")
                    .font(.nunito(18, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(1)
                Spacer()
            }
            
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)
                .padding(.vertical, 8)
            
            MetricCard(
                title: "Current Weight",
                value: viewModel.formattedCurrentWeight,
                subtitle: viewModel.formattedMonthlyChange
            )
            
            MetricCard(
                title: "Target Weight",
                value: viewModel.formattedTargetWeight,
                subtitle: "Goal"
            )
            
            Spacer()
        }
        .onAppear {
            viewModel.loadSummary()
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.largeTitle)
                .bold()
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    ProgressScreenView()
}
