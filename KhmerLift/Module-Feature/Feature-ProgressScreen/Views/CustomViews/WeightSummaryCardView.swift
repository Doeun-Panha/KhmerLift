//
//  WeightSummaryCardView.swift
//  KhmerLift
//

import SwiftUI
import Charts

struct WeightSummaryCardView: View {
    let viewModel: ProgressScreenViewModel
    let onEditTap: () -> Void
    
    var body: some View {
        containerView
    }
}

extension WeightSummaryCardView {
    private var containerView: some View {
        VStack(spacing: 16) {
            headerView
            
            HStack {
                textContent
                
                Spacer()
                
                if viewModel.summary.recentLogs.count >= 2 {
                    graphView
                } else {
                    graphNoDataPlaceholderView
                    
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private var headerView: some View {
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
    }
    
    private var textContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.formattedCurrentTitle)
                    .font(.nunito(16, weight: .light))
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.75))
                
                Text(viewModel.formattedCurrentWeight)
                    .font(.nunito(22, weight: .semibold))
                    .foregroundStyle(.white)
                    .tracking(1)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Goal")
                    .font(.nunito(16, weight: .light))
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.75))
                
                Text(viewModel.formattedTargetWeight)
                    .font(.nunito(22, weight: .semibold))
                    .foregroundStyle(.white)
                    .tracking(1)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.formattedChangeTitle)
                    .font(.nunito(16, weight: .light))
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.75))
                
                Text(viewModel.formattedMonthlyChange)
                    .font(.nunito(22, weight: .semibold))
                    .foregroundStyle(.white)
                    .tracking(1)
            }
        }
    }
    
    private var graphView: some View {
        Chart(viewModel.summary.recentLogs) { log in
            LineMark(
                x: .value("Date", log.date),
                y: .value("Weight", log.bodyWeight)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Color.cyan)
            .lineStyle(StrokeStyle(lineWidth: 2.5))
            
            AreaMark(
                x: .value("Date", log.date),
                y: .value("Weight", log.bodyWeight)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                LinearGradient(
                    stops: [
                        .init(color: Color.cyan.opacity(0.35), location: 0.0),
                        .init(color: Color.cyan.opacity(0.175), location: 0.025),
                        .init(color: Color.cyan.opacity(0.00), location: 0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            RuleMark(y: .value("Goal", viewModel.targetWeight))
                .foregroundStyle(Color.cyan.opacity(0.8))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                .annotation(position: .top, alignment: .trailing) {
                    Text("Goal")
                        .font(.nunito(10, weight: .semibold))
                        .foregroundStyle(.cyan.opacity(0.8))
                }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: yDomain)
        .frame(height: 200)
        .clipped()
    }
    
    private var graphNoDataPlaceholderView: some View {
        VStack {
            Spacer()
            
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.75))
            
            Text("Not Enough Data")
                .font(.nunito(16, weight: .light))
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.75))
            
            Spacer()
        }
    }
}

extension WeightSummaryCardView {
    private var yDomain: ClosedRange<Double> {
        var weights = viewModel.summary.recentLogs.map(\.bodyWeight)
        weights.append(viewModel.targetWeight)
        
        guard let minW = weights.min(), let maxW = weights.max() else {
            return 50.0...100.0
        }
        
        if minW == maxW {
            return (minW - 2.0)...(maxW + 2.0)
        }
        
        let padding = 1.5
        return (minW - padding)...(maxW + padding)
    }
}
