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
                
                Spacer()
                
                if viewModel.summary.recentLogs.count >= 2 {
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
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartYScale(domain: yDomain)
                    .frame(height: 200)
                    .clipped()
                } else {
                    Text("Not Enough Data")
                        .font(.nunito(14, weight: .light))
                        .foregroundStyle(.gray)
                }
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private var yDomain: ClosedRange<Double> {
        let weights = viewModel.summary.recentLogs.map(\.bodyWeight)
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
