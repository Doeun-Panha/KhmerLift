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

@MainActor
@Observable
final class PasscodeViewModel {
    enum Mode {
        case setup
        case unlock
    }
    
    enum SetupStep {
        case create
        case confirm
    }
    
    let mode: Mode
    let pinLength = 6
    
    private let passcodeKey = "isPasscodeEnabled"
    private(set) var setupStep: SetupStep = .create
    
    var enteredPin: String = ""
    var firstPinAttempt: String = ""
    
    var isSuccess: Bool = false
    var errorTrigger: Int = 0
    
    var titleText: String {
        switch mode {
        case .setup:
            return setupStep == .create ? "Create a Passcode" : "Confirm your Passcode"
            
        case .unlock:
            return "Enter Passcode"
        }
    }
    
    var toast: ToastConfig? = nil
    
    init(
        mode: Mode
    ) {
        self.mode = mode
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
        switch mode {
        case .setup:
            handleSetupFlow()
            
        case .unlock:
            handleUnlockFlow()
        }
    }
    
    private func handleSetupFlow() {
        switch setupStep {
        case .create:
            firstPinAttempt = enteredPin
            enteredPin = ""
            setupStep = .confirm
            
        case .confirm:
            if enteredPin == firstPinAttempt {
                if savePasscodeToKeychain(enteredPin) {
                    isSuccess = true
                } else {
                    showToast(
                        message: "Failed to save passcode securely.",
                        icon: "exclamationmark.triangle.fill",
                        tintColor: .red
                    )
                    errorTrigger += 1
                    enteredPin = ""
                    firstPinAttempt = ""
                    setupStep = .create
                }
            } else {
                showToast(
                    message: "Entered Passcodes do not match.",
                    icon: "xmark.octagon.fill",
                    tintColor: .red
                )
                errorTrigger += 1
                enteredPin = ""
                firstPinAttempt = ""
                setupStep = .create
            }
        }
    }
    
    private func handleUnlockFlow() {
        let savedPasscode = KeychainHelper.getPasscode()
        
        if enteredPin == savedPasscode {
            isSuccess = true
        } else {
            showToast(
                message: "Incorrect Passcode",
                icon: "xmark.octagon.fill",
                tintColor: .red
            )
            errorTrigger += 1
            enteredPin = ""
        }
    }
    
    @discardableResult
    private func savePasscodeToKeychain(_ code: String) -> Bool {
        let success = KeychainHelper.savePasscode(code)
        if success {
            UserDefaults.standard.set(true, forKey: passcodeKey)
        }
        return success
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
