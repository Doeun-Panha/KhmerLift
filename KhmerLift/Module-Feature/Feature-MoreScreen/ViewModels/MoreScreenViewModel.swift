import SwiftUI
import Observation

@MainActor
@Observable
final class MoreScreenViewModel {
    private let biometricService: BiometricServiceProtocol
    private let faceIDKey = "isFaceIDEnabled"
    private let passcodeKey = "isPasscodeEnabled"
    private let selectedBackgroundKey = "selectedBackgroundFileName"
    
    var enableFaceID: Bool = false
    var navigateToFaceID: Bool = false
    var showSettingsAlert: Bool = false
    var toast: ToastConfig? = nil
    
    var isAddinBackground: Bool = false
    var newBackgroundName: String = ""
    
    var enablePasscode: Bool = false
    
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
    }
    
    private func savePasscodePreference(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: passcodeKey)
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
