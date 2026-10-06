//
//  BackgroundModel.swift
//  KhmerLift
//
//  Created by Panha on 6/10/26.
//

import Foundation

struct BackgroundModel: SelectableItem, Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let fileName: String
    let fileType: String
    
    var displayName: String {
        return name
    }
}
