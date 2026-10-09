//
//  BouncyButtonStyle.swift
//  KhmerLift
//
//  Created by Panha on 8/10/26.
//

import SwiftUI

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(
                .spring(response: 0.25, dampingFraction: 0.45, blendDuration: 0),
                value: configuration.isPressed
            )
    }
}
