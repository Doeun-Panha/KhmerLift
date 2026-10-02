//
//  ProgressScreenService.swift
//  KhmerLift
//
//  Created by Panha on 30/9/26.
//

import Foundation
import SwiftData

@MainActor
protocol ProgressScreenServiceProtocol: AnyObject {
    func saveTargetWeight(_ weight: Double)
    func fetchTargetWeight() -> Double
}

@MainActor
final class ProgressScreenService: ProgressScreenServiceProtocol {
    private let context: ModelContext
    private let targetWeightKey = "targetBodyWeight"
    
    init(modelContainer: ModelContainer? = nil) {
        let container = modelContainer ?? SwiftDataContainer.shared
        self.context = container.mainContext
    }
    
    func saveTargetWeight(_ weight: Double) {
        UserDefaults.standard.set(weight, forKey: targetWeightKey)
    }
    
    func fetchTargetWeight() -> Double {
        let saved = UserDefaults.standard.double(forKey: targetWeightKey)
        return saved > 0 ? saved : 55.0
    }
}
