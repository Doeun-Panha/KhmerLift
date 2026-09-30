//
//  MainScreenModel.swift
//  KhmerLift
//
//  Created by Panha on 29/9/26.
//

import Foundation

enum TabItem: String, CaseIterable, Identifiable {
    case home
    case progress
    case more

    var id: String { rawValue }
    
    var title: String { rawValue.capitalized }
    var selectedIcon: String { "\(rawValue)-selected-icon" }
    var unselectedIcon: String { "\(rawValue)-unselected-icon" }
}
