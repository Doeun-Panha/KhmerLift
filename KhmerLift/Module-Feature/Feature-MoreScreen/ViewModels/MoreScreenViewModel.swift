import SwiftUI
import Observation

@MainActor
@Observable
final class MoreScreenViewModel {
    private let biometricService: BiometricServiceProtocol
    private let faceIDKey = "isFaceIDEnabled"
    
    var enableFaceID: Bool = false
    var navigateToFaceID: Bool = false
    var showSettingsAlert: Bool = false
    var toast: ToastConfig? = nil
    
    init(
        biometricService: BiometricServiceProtocol? = nil
    ) {
        let biometricService = biometricService ?? BiometricService()
        self.biometricService = biometricService
        
        self.enableFaceID = UserDefaults.standard.bool(forKey: faceIDKey)
    }
    
    func handleFaceIDToggleChange(_ isEnabled: Bool) {
        self.enableFaceID = isEnabled
        
        if !isEnabled {
            let wasPreviouslyEnabled = UserDefaults.standard.bool(forKey: faceIDKey)
            saveFaceIDPreference(false)
            
            if wasPreviouslyEnabled {
                showToast(
                    message: "Face ID disabled.",
                    icon: "lock.slash.fill",
                    tintColor: .gray
                )
            }
            return
        }
        
        let status = biometricService.checkFaceIDStatus()
        
        switch status {
        case .available:
            Task {
                try? await Task.sleep(for: .milliseconds(250))
                self.navigateToFaceID = true
            }
            
        case .notEnrolled:
            self.enableFaceID = false
            saveFaceIDPreference(false)
            self.showSettingsAlert = true
            
        case .notAvailable:
            self.enableFaceID = false
            saveFaceIDPreference(false)
            showToast(
                message: "Face ID is not available on this device.",
                icon: "xmark.octagon.fill",
                tintColor: .red
            )
        }
    }
    
    func handleFaceIDDismissal() {
        if !UserDefaults.standard.bool(forKey: faceIDKey) {
            self.enableFaceID = false
        }
    }
    
    func confirmFaceIDSetupSuccess() {
        saveFaceIDPreference(true)
        showToast(
            message: "Face ID enabled successfully!",
            icon: "checkmark.circle.fill",
            tintColor: .green
        )
    }
    
    func showToast(message: String, icon: String? = "info.circle.fill", tintColor: Color = .blue) {
        let config = ToastConfig(message: message, icon: icon, tintColor: tintColor)
        self.toast = config
        
        Task {
            try? await Task.sleep(for: .seconds(3))
            if self.toast == config {
                self.toast = nil
            }
        }
    }
    
    private func saveFaceIDPreference(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: faceIDKey)
    }
}
