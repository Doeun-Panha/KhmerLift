//
//  BiometricChecker.swift
//  KhmerLift
//
//  Created by Panha on 5/10/26.
//

import LocalAuthentication

public enum FaceIDStatus {
    case available
    case notEnrolled
    case notAvailable
}

public protocol BiometricServiceProtocol {
    func checkFaceIDStatus() -> FaceIDStatus
    func authenticate(reason: String) async throws -> Bool
    func cancelAuthentication()
}

@MainActor
public final class BiometricService: BiometricServiceProtocol {
    private var currentContext: LAContext?
    
    public init() {}
    
    public func checkFaceIDStatus() -> FaceIDStatus {
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
    
    public func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        self.currentContext = context
        
        defer { self.currentContext = nil }
        
        return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
    }
    
    public func cancelAuthentication() {
        currentContext?.invalidate()
        currentContext = nil
    }
}
