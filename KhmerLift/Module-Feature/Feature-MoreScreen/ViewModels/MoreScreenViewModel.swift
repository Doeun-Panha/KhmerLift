import SwiftUI
import Observation

@MainActor
@Observable
final class MoreScreenViewModel {
    private let selectedBackgroundKey = "selectedBackgroundFileName"
    
    private let biometricService: BiometricServiceProtocol
    
    private let faceIDKey = "isFaceIDEnabled"
    private let passcodeKey = "isPasscodeEnabled"
    
    var enableFaceID: Bool = false
    var navigateToFaceID: Bool = false
    var showSettingsAlert: Bool = false
    var toast: ToastConfig? = nil
    
    var enablePasscode: Bool = false
    var navigateToPasscodeSetup = false
    
    var isAddinBackground: Bool = false
    var newBackgroundName: String = ""
    
    let availableBackgrounds: [BackgroundModel] = [
        BackgroundModel(id: "bike-video", name: "Bike", fileName: "bike-video", fileType: "mp4"),
        BackgroundModel(id: "bike-nature-video", name: "Bike Nature", fileName: "bike-nature-video", fileType: "mp4"),
        BackgroundModel(id: "berserker-nature-video", name: "Berserker", fileName: "berserker-nature-video", fileType: "mp4"),
        BackgroundModel(id: "blackhole-video", name: "Blackhole", fileName: "blackhole-video", fileType: "mp4"),
        BackgroundModel(id: "cycling-sunset-video", name: "Cycling Sunset", fileName: "cycling-sunset-video", fileType: "mp4"),
    ]
    
    var selectedBackground: BackgroundModel? {
        didSet {
            if let selectedBackground {
                UserDefaults.standard.set(selectedBackground.fileName, forKey: selectedBackgroundKey)
            }
        }
    }
    
    init(
        biometricService: BiometricServiceProtocol? = nil
    ) {
        let biometricService = biometricService ?? BiometricService()
        self.biometricService = biometricService
        
        self.enableFaceID = UserDefaults.standard.bool(forKey: faceIDKey)
        self.enablePasscode = UserDefaults.standard.bool(forKey: passcodeKey)
        
        let savedFileName = UserDefaults.standard.string(forKey: selectedBackgroundKey) ?? "bike-video"
        self.selectedBackground = availableBackgrounds.first(where: { $0.fileName == savedFileName }) ?? availableBackgrounds.first
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
        
        guard enablePasscode else {
            self.enableFaceID = false
            saveFaceIDPreference(false)
            
            showToast(
                message: "Please set up a passcode first before enabling Face ID.",
                icon: "lock.trianglebadge.exclamationmark.fill",
                tintColor: .orange
            )
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
        self.enableFaceID = UserDefaults.standard.bool(forKey: faceIDKey)
        self.navigateToFaceID = false
    }
    
    func confirmFaceIDSetupSuccess() {
        saveFaceIDPreference(true)
        self.enableFaceID = true
        self.navigateToFaceID = false
        
        showToast(
            message: "Face ID enabled successfully!",
            icon: "checkmark.circle.fill",
            tintColor: .green
        )
    }
    
    private func saveFaceIDPreference(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: faceIDKey)
    }
    
    func handlePasscodeToggleChange(_ isEnabled: Bool) {
        self.enablePasscode = isEnabled
        
        if isEnabled {
            Task {
                try? await Task.sleep(for: .milliseconds(250))
                self.navigateToPasscodeSetup = true
            }
        } else {
            guard !enableFaceID else {
                self.enablePasscode = true
                
                showToast(
                    message: "Please turn off Face ID first before disabling Passcode.",
                    icon: "lock.trianglebadge.exclamationmark.fill",
                    tintColor: .orange
                )
                return
            }
            
            removePasscodeFromKeychain()
            savePasscodePreference(false)
            self.enablePasscode = false
            
            showToast(
                message: "Passcode disabled.",
                icon: "lock.slash.fill",
                tintColor: .gray
            )
        }
    }
    
    func handlePasscodeDismissal() {
        self.enablePasscode = UserDefaults.standard.bool(forKey: passcodeKey)
        self.navigateToPasscodeSetup = false
    }
    
    func confirmPasscodeSetupSuccess() {
        savePasscodePreference(true)
        self.enablePasscode = true
        self.navigateToPasscodeSetup = false

        showToast(
            message: "Passcode enabled successfully!",
            icon: "checkmark.circle.fill",
            tintColor: .green
        )
    }
    
    private func savePasscodePreference(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: passcodeKey)
    }
    
    private func removePasscodeFromKeychain() {
        _ = KeychainHelper.deletePasscode()
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
}
