//
//  KhmerLiftAppScreenViewModel.swift
//  KhmerLift
//
//  Created by Panha on 6/10/26.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class KhmerLiftAppScreenViewModel {
    enum LockState {
        case checking
        case locked
        case unlocked
    }
    
    var lockState: LockState = .checking
    var errorMessage: String? = nil
    
    var showPasscodeSheet: Bool = false {
        didSet {
            if showPasscodeSheet {
                biometricService.cancelAuthentication()
            }
        }
    }
    private(set) var isAuthenticating: Bool = false
    private var hasAutoAttemptedFaceID: Bool = false
    
    private let biometricService: BiometricServiceProtocol
    private let faceIDKey = "isFaceIDEnabled"
    private let passcodeKey = "isPasscodeEnabled"
    
    init(
        biometricService: BiometricServiceProtocol? = nil
    ) {
        let biometricService = biometricService ?? BiometricService()
        self.biometricService = biometricService
    }
    
    var isFaceIDEnabled: Bool {
        UserDefaults.standard.bool(forKey: faceIDKey)
    }
    
    var isPasscodeEnabled: Bool {
        UserDefaults.standard.bool(forKey: passcodeKey)
    }
    
    var isLockEnabled: Bool {
        isFaceIDEnabled || isPasscodeEnabled
    }
    
    func checkAppLockOnLaunch() async {
        guard isLockEnabled else {
            lockState = .unlocked
            return
        }
        
        lockState = .locked
        
        if isFaceIDEnabled {
            hasAutoAttemptedFaceID = true
            await authenticateWithFaceID()
        }
    }
    
    func authenticateWithFaceID() async {
        guard !isAuthenticating else { return }
        
        isAuthenticating = true
        defer { isAuthenticating = false }
        
        errorMessage = nil
        
        guard biometricService.checkFaceIDStatus() == .available else {
            errorMessage = "Face ID is not available on this device"
            return
        }
        
        do {
            let success = try await biometricService.authenticate(reason: "Unlock KhmerLift to continue")
            if success {
                unlockApp()
            } else {
                errorMessage = "Authentication failed. Try again."
            }
        } catch {
            errorMessage = "Authentication canceled."
        }
    }
    
    func unlockApp() {
        lockState = .unlocked
        showPasscodeSheet = false
        hasAutoAttemptedFaceID = false
        errorMessage = nil
    }
    
    func handleScenePhaseChange(_ newPhase: ScenePhase) {
        guard isLockEnabled else { return }
        
        if newPhase == .background {
            lockState = .locked
            showPasscodeSheet = false
            hasAutoAttemptedFaceID = false
            biometricService.cancelAuthentication()
        } else if newPhase == .active && lockState == .locked {
            if isFaceIDEnabled && !hasAutoAttemptedFaceID && !showPasscodeSheet {
                hasAutoAttemptedFaceID = true
                Task { await authenticateWithFaceID() }
            }
        }
    }
}
