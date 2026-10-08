//
//  ToastBannerView.swift
//  KhmerLift
//
//  Created by Panha on 29/9/26.
//

import SwiftUI

struct ToastConfig: Equatable {
    enum Style {
        case success
        case error
        case warning
        case info
    }

    let id: UUID
    let message: String
    var icon: String?
    var tintColor: Color
    var style: Style

    init(
        id: UUID = UUID(),
        message: String,
        icon: String? = "info.circle.fill",
        tintColor: Color = .blue,
        style: Style = .info
    ) {
        self.id = id
        self.message = message
        self.icon = icon
        self.tintColor = tintColor
        self.style = style
    }

    static func success(_ message: String, icon: String = "checkmark.circle.fill") -> ToastConfig {
        ToastConfig(message: message, icon: icon, tintColor: .green, style: .success)
    }

    static func error(_ message: String, icon: String = "exclamationmark.triangle.fill") -> ToastConfig {
        ToastConfig(message: message, icon: icon, tintColor: .red, style: .error)
    }

    static func warning(_ message: String, icon: String = "exclamationmark.triangle.fill") -> ToastConfig {
        ToastConfig(message: message, icon: icon, tintColor: .orange, style: .warning)
    }

    static func info(_ message: String, icon: String = "info.circle.fill") -> ToastConfig {
        ToastConfig(message: message, icon: icon, tintColor: .blue, style: .info)
    }
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

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            ToastBannerView(config: .success("Face ID enabled successfully!"))
            ToastBannerView(config: .error("Please set up Face ID in iOS Settings first."))
            ToastBannerView(config: .info("Looking for face...", icon: "faceid"))
        }
    }
}
