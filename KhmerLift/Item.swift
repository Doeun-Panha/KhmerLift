//
//  Item.swift
//  KhmerLift
//
//  Created by Panha on 16/9/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
