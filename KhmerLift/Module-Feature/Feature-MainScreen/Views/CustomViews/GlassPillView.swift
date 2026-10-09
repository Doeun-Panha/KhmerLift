//
//  GlassPillView.swift
//  KhmerLift
//
//  Created by Panha on 9/10/26.
//

import SwiftUI

struct GlassPillView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        .white.opacity(0.35),
                        .white.opacity(0.14),
                        .white.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.75),
                                .white.opacity(0.25),
                                .white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            .shadow(color: .black.opacity(0.20), radius: 8, x: 0, y: 4)
    }
}
