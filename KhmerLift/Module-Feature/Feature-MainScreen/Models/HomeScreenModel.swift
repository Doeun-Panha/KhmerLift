//
//  HomeScreenModel.swift
//  KhmerLift
//
//  Created by Panha on 21/9/26.
//

import SwiftUI

protocol SelectableItem: Identifiable, Hashable {
    var displayName: String { get }
}

struct MuscleCategory: SelectableItem {
    let id = UUID()
    let name: String
    var displayName: String { name }
}

struct Exercise: SelectableItem {
    let id = UUID()
    let categoryId: UUID
    let name: String
    var displayName: String { name }
}

enum FormField: Hashable {
    case bodyWeight
    case weight
    case repetition
}

enum TabItem: String, CaseIterable {
    case home
    case progress
    case more
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .progress: return "Progress"
        case .more: return "More"
        }
    }
    
    var selectedIcon: String {
        switch self {
        case .home: return "home-selected-icon"
        case .progress: return "progress-selected-icon"
        case .more: return "more-selected-icon"
        }
    }
    
    var unselectedIcon: String {
        switch self {
        case .home: return "home-unselected-icon"
        case .progress: return "progress-unselected-icon"
        case .more: return "more-unselected-icon"
        }
    }
}
