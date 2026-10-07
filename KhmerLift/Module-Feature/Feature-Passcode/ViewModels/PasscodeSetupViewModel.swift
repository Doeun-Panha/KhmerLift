//
//  PasscodeSetupViewModel.swift
//  KhmerLift
//
//  Created by Panha on 7/10/26.
//

import Observation
import Foundation
import UIKit
import SwiftUI

enum PasscodeStep {
    case create
    case confirm
}

@MainActor
@Observable
final class PasscodeSetupViewModel {
    private let backgroundKey = "selectedBackgroundFileName"
    var selectedBackgroundFileName: String = "bike-video"
    
    private let passcodeKey = "isPasscodeEnabled"
    
    var step: PasscodeStep = .create
    var enteredPin: String = ""
    var firstPinAttempt: String = ""
    
    var titleText: String {
        step == .create ? "Create a Passcode" : "Confirm Passcode"
    }
    
    var isSuccess: Bool = false
    var errorTrigger: Int = 0
    
    let pinLength = 6
    
    var toast: ToastConfig? = nil
    
    init() {
        self.selectedBackgroundFileName = UserDefaults.standard.string(forKey: backgroundKey) ?? "bike-video"
        
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.reloadBackgroundPreference()
            }
        }
    }
    
    private func reloadBackgroundPreference() {
        let updatedBackground = UserDefaults.standard.string(forKey: backgroundKey) ?? "bike-video"
        if selectedBackgroundFileName != updatedBackground {
            selectedBackgroundFileName = updatedBackground
        }
    }
    
    func appendDigit(_ digit: String) {
        guard enteredPin.count < pinLength else { return }
        enteredPin.append(digit)
        
        if enteredPin.count == pinLength {
            handlePinCompletion()
        }
    }
    
    func deleteDigit() {
        guard !enteredPin.isEmpty else { return }
        enteredPin.removeLast()
    }
    
    private func handlePinCompletion() {
        switch step {
        case .create:
            firstPinAttempt = enteredPin
            enteredPin = ""
            step = .confirm
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        case .confirm:
            if enteredPin == firstPinAttempt {
                savePasscodeToKeychain(enteredPin)
                isSuccess = true
            } else {
                showToast(
                    message: "Entered Passcodes do not match.",
                    icon: "xmark.octagon.fill",
                    tintColor: .red
                )
                errorTrigger += 1
                enteredPin = ""
                firstPinAttempt = ""
                step = .create
            }
        }
    }
    
    private func savePasscodeToKeychain(_ code: String) {
        UserDefaults.standard.set(true, forKey: passcodeKey)
    }
    
    func showToast(
        message: String,
        icon: String? = "info.circle.fill",
        tintColor: Color = .blue
    ) {
        let config = ToastConfig(
            message: message,
            icon: icon,
            tintColor: tintColor
        )
        self.toast = config
        
        Task {
            try? await Task.sleep(for: .seconds(3))
            if self.toast == config {
                self.toast = nil
            }
        }
    }
}
