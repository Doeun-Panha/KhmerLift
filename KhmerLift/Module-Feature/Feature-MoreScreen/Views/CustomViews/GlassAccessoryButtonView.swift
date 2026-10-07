//
//  GlassAccessoryButtonView.swift
//  KhmerLift
//
//  Created by Panha on 6/10/26.
//

import SwiftUI

struct GlassAccessoryButtonView: View {
    let name: String
    let assessory: String
    let action: () -> Void
    
    let cornerRadius: CGFloat = 32.0

    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(name)
                    .font(.nunito(16, weight: .semibold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: assessory)
                    .font(.nunito(16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding()
            .glassEffect(.clear, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
