//
//  ToastBannerView.swift
//  KhmerLift
//
//  Created by Panha on 29/9/26.
//

import SwiftUI

struct ToastConfig: Equatable {
    let message: String
    var icon: String? = "info.circle.fill"
    var tintColor: Color = .blue
}

struct ToastBannerView: View {
    let config: ToastConfig

    var body: some View {
        HStack(spacing: 12) {
            if let icon = config.icon {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(config.tintColor)
            }

            Text(config.message)
                .font(.nunito(14, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(config.tintColor.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 16)
    }
}

struct ToastModifier: ViewModifier {
    let config: ToastConfig?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let config {
                    ToastBannerView(config: config)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: config)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            ToastBannerView(config: ToastConfig(
                message: "Face ID enabled successfully!",
                icon: "checkmark.circle.fill",
                tintColor: .green
            ))
            
            ToastBannerView(config: ToastConfig(
                message: "Please set up Face ID in iOS Settings first.",
                icon: "exclamationmark.triangle.fill",
                tintColor: .red
            ))
            
            ToastBannerView(config: ToastConfig(
                message: "Looking for face...",
                icon: "faceid",
                tintColor: Color(red: 0.35, green: 0.65, blue: 1.0)
            ))
        }
    }
}
