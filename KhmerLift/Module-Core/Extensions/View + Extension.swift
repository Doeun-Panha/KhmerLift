//
//  View + Extension.swift
//  KhmerLift
//
//  Created by Panha on 18/9/26.
//

import SwiftUI

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            dismissKeyboard()
        }
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func toast(_ config: ToastConfig?) -> some View {
        self.modifier(ToastModifier(config: config))
    }
}
