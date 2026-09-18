//
//  Font+Extension.swift
//  KhmerLift
//
//  Created by Panha on 17/9/26.
//

import SwiftUI

extension Font {
    static func nunito(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .custom("Nunito", size: size).weight(weight)
    }
}

