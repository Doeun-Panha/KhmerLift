//
//  GlassActionButton.swift
//  KhmerLift
//
//  Created by Panha on 3/11/26.
//

import SwiftUI

struct GlassLogButton: View {
    let title: String
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.nunito(15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12.5)
                    .contentShape(Rectangle())
            }
            .background(Color.cyan.opacity(0.8))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .glassEffect(.clear, in: Capsule())
    }
}
