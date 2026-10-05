//
//  ProgressScreenModel.swift
//  KhmerLift
//
//  Created by Panha on 30/9/26.
//

import Foundation

struct BodyWeightSummary {
    let currentWeight: Double?
    let latestLogDate: Date?
    let monthlyChange: Double?
    let comparisonDate: Date?
    let targetWeight: Double
    let recentLogs: [BodyWeightLog]
    
    init(
        currentWeight: Double? = nil,
        latestLogDate: Date? = nil,
        monthlyChange: Double? = nil,
        comparisonDate: Date? = nil,
        targetWeight: Double = 55.0,
        recentLogs: [BodyWeightLog] = []
        
    ) {
        self.currentWeight = currentWeight
        self.latestLogDate = latestLogDate
        self.monthlyChange = monthlyChange
        self.comparisonDate = comparisonDate
        self.targetWeight = targetWeight
        self.recentLogs = recentLogs
    }
}
