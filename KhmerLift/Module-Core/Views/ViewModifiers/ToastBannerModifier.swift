//
//  ToastBannerModifier.swift
//  KhmerLift
//
//  Created by Panha on 8/10/26.
//

import SwiftUI

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
