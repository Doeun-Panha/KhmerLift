//
//  ProgressScreenViewModel.swift
//  KhmerLift
//
//  Created by Panha on 30/9/26.
//

import Foundation
import Observation

@Observable
final class ProgressScreenViewModel {
    private let service: ProgressScreenServiceProtocol
    
    private(set) var summary: BodyWeightSummary?
    
    init(service: ProgressScreenServiceProtocol? = nil) {
        self.service = service ?? ProgressScreenService()
    }
    
    var formattedCurrentWeight: String {
        guard let weight = summary?.currentWeight else { return "-- kg" }
        return String(format: "%.1f kg", weight)
    }
    
    var formattedMonthlyChange: String {
        guard let change = summary?.monthlyChange else { return "No data for 30 days" }
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", change)) kg this month"
    }
    
    var formattedTargetWeight: String {
        guard let target = summary?.targetWeight else { return "-- kg" }
        return String(format: "%.1f kg", target)
    }
    
    func loadSummary() {
        self.summary = service.fetchBodyWeightSummary()
    }
}
