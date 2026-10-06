//
//  FaceIDViewModel.swift
//  KhmerLift
//
//  Created by Panha on 6/10/26.
//

import Foundation
import Combine

@MainActor
final class FaceIDViewModel: ObservableObject {
    private let biometricService: BiometricServiceProtocol
    let cameraManager = CameraManager()
    
    @Published var timer: Int
    @Published var status: String
    @Published var isMuted: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var shouldDismiss: Bool = false
    
    var onSuccess: (() -> Void)?
    var onFailure: (() -> Void)?
    
    init(
        biometricService: BiometricServiceProtocol? = nil,
        initialTimer: Int = 19,
        initialStatus: String = "No face detected",
        onSuccess: (() -> Void)? = nil,
        onFailure: (() -> Void)? = nil
    ) {
        let biometricService = biometricService ?? BiometricService()
        self.biometricService = biometricService
        self.timer = initialTimer
        self.status = initialStatus
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    func onViewAppear() {
        cameraManager.checkPermissionAndStart()
        Task {
            await authenticateWithFaceID()
        }
    }
    
    func onViewDisappear() {
        cameraManager.stopSession()
    }
    
    func toggleMute() {
        isMuted.toggle()
    }
    
    private func authenticateWithFaceID() async {
        try? await Task.sleep(for: .seconds(1))
        
        guard biometricService.checkFaceIDStatus() == .available else {
            status = "Face ID unavailable"
            handleCancel()
            return
        }
        
        do {
            let success = try await biometricService.authenticate(
                reason: "Verify Face ID to enable security feature."
            )
            
            if success {
                isAuthenticated = true
                status = "Verification Successful"
                try? await Task.sleep(for: .seconds(1))
                onSuccess?()
                shouldDismiss = true
            } else {
                handleCancel()
            }
        } catch {
            status = "Authentication Canceled"
            handleCancel()
        }
    }
    
    private func handleCancel() {
        onFailure?()
        shouldDismiss = true
    }
}
