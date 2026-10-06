//
//  BiometricChecker.swift
//  KhmerLift
//
//  Created by Panha on 5/10/26.
//

import LocalAuthentication

enum FaceIDStatus {
    case available
    case notEnrolled
    case notAvailable
}

protocol BiometricServiceProtocol {
    func checkFaceIDStatus() -> FaceIDStatus
    func authenticate(reason: String) async throws -> Bool
}

final class BiometricService: BiometricServiceProtocol {
    func checkFaceIDStatus() -> FaceIDStatus {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let laError = error as? LAError, laError.code == .biometryNotEnrolled {
                return .notEnrolled
            }
            return .notAvailable
        }
        
        return context.biometryType == .faceID ? .available : .notAvailable
    }
    
    func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
    }
}
