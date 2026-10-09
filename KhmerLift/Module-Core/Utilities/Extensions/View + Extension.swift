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
    
    func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    func triggerWarningHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    func triggerErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    func toast(_ config: ToastConfig?) -> some View {
        self.modifier(ToastModifier(config: config))
    }
    
    func appBackground() -> some View {
        modifier(AppBackgroundModifier())
    }
}
