//
//  ToastBannerModifier.swift
//  KhmerLift
//
//  Created by Panha on 8/10/26.
//

import SwiftUI
import AudioToolbox
import UIKit

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
            .task(id: config) {
                if let config {
                    triggerToastFeedback(for: config)
                }
            }
    }

    private func triggerToastFeedback(for config: ToastConfig) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()

        switch config.style {
        case .success:
            generator.notificationOccurred(.success)
//            AudioServicesPlaySystemSound(1054)
        case .warning:
            generator.notificationOccurred(.warning)
//            AudioServicesPlaySystemSound(1007)
        case .error:
//            generator.notificationOccurred(.error)
            AudioServicesPlaySystemSound(1053)
        case .info:
            generator.notificationOccurred(.warning)
//            AudioServicesPlaySystemSound(1000)
        }
    }
}
