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
    private(set) var isAuthenticating: Bool = false
    
    private let biometricService: BiometricServiceProtocol
    private let faceIDKey = "isFaceIDEnabled"
    
    init(
        biometricService: BiometricServiceProtocol? = nil
    ) {
        let biometricService = biometricService ?? BiometricService()
        self.biometricService = biometricService
    }
    
    var isFaceIDEnabled: Bool {
        UserDefaults.standard.bool(forKey: faceIDKey)
    }
    
    func checkAppLockOnLaunch() async {
        guard isFaceIDEnabled else {
            lockState = .unlocked
            return
        }
        
        lockState = .locked
        await authenticate()
    }
    
    func authenticate() async {
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
                lockState = .unlocked
            } else {
                errorMessage = "Authentication failed. Try again."
            }
        } catch {
            errorMessage = "Authentication canceled."
        }
    }
    
    func handleScenePhaseChange(_ newPhase: ScenePhase) {
        guard isFaceIDEnabled else { return }
        
        if newPhase == .background {
            lockState = .locked
        } else if newPhase == .active && lockState == .locked {
            Task { await authenticate() }
        }
    }
}
