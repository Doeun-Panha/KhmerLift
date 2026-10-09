//
//  MoreScreenViewModel.swift
//  KhmerLift
//
//  Created by Panha on 21/9/26.
//

import SwiftUI
import Observation
import PhotosUI

@MainActor
@Observable
final class MoreScreenViewModel {
    private enum Keys {
        static let selectedBackgroundFileName = "selectedBackgroundFileName"
        static let selectedBackgroundFileType = "selectedBackgroundFileType"
        static let faceID = "isFaceIDEnabled"
        static let passcode = "isPasscodeEnabled"
    }
    
    var toast: ToastConfig? = nil
    private var toastTask: Task<Void, Never>?

    private let biometricService: BiometricServiceProtocol

    var enableFaceID: Bool = false
    var navigateToFaceIDSetup: Bool = false
    var navigateToFaceIDDisable: Bool = false
    var showSettingsAlert: Bool = false
    
    var enablePasscode: Bool = false
    var navigateToPasscodeSetup = false
    var navigateToPasscodeDisable: Bool = false
    
    let availableBackgrounds: [BackgroundModel] = [
        BackgroundModel(id: "bike-video", name: "Bike", fileName: "bike-video", fileType: "mp4"),
        BackgroundModel(id: "bike-nature-video", name: "Bike Nature", fileName: "bike-nature-video", fileType: "mp4"),
        BackgroundModel(id: "mid-night-video", name: "Mid Night", fileName: "mid-night-video", fileType: "mov"),
        BackgroundModel(id: "blackhole-video", name: "Blackhole", fileName: "blackhole-video", fileType: "mp4"),
        BackgroundModel(id: "cycling-sunset-video", name: "Cycling Sunset", fileName: "cycling-sunset-video", fileType: "mp4"),
    ]
    
    var isAddingBackground: Bool = false
    var newBackgroundName: String = ""
    
    var selectedBackground: BackgroundModel? {
        didSet {
            if let selectedBackground {
                UserDefaults.standard.set(selectedBackground.fileName, forKey: Keys.selectedBackgroundFileName)
                UserDefaults.standard.set(selectedBackground.fileType, forKey: Keys.selectedBackgroundFileType)
            }
        }
    }
    
    init(
        biometricService: BiometricServiceProtocol? = nil
    ) {
        let biometricService = biometricService ?? BiometricService()
        self.biometricService = biometricService
        
        self.enableFaceID = UserDefaults.standard.bool(forKey: Keys.faceID)
        self.enablePasscode = UserDefaults.standard.bool(forKey: Keys.passcode)
        
        let savedFileName = UserDefaults.standard.string(forKey: Keys.selectedBackgroundFileName) ?? "bike-video"
        self.selectedBackground = availableBackgrounds.first(where: { $0.fileName == savedFileName }) ?? availableBackgrounds.first
    }
}

extension MoreScreenViewModel {
    func showToast(_ config: ToastConfig) {
        toastTask?.cancel()
        
        self.toast = config
        
        toastTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            
            if self.toast == config {
                self.toast = nil
            }
        }
    }
}

extension MoreScreenViewModel {
    func handleFaceIDToggleChange(_ isEnabled: Bool) {
        self.enableFaceID = isEnabled
        
        if !isEnabled {
            let wasPreviouslyEnabled = UserDefaults.standard.bool(forKey: Keys.faceID)
            
            if wasPreviouslyEnabled {
                Task {
                    try? await Task.sleep(for: .milliseconds(250))
                    self.navigateToFaceIDDisable = true
                }
            } else {
                saveFaceIDPreference(false)
            }
            
            return
        }
        
        guard enablePasscode else {
            self.enableFaceID = false
            saveFaceIDPreference(false)
            
            showToast(.warning("Please set up a passcode first before enabling Face ID.", icon: "lock.trianglebadge.exclamationmark.fill"))
            return
        }
        
        let status = biometricService.checkFaceIDStatus()
        
        switch status {
        case .available:
            Task {
                try? await Task.sleep(for: .milliseconds(250))
                self.navigateToFaceIDSetup = true
            }
            
        case .notEnrolled:
            self.enableFaceID = false
            saveFaceIDPreference(false)
            self.showSettingsAlert = true
            
        case .notAvailable:
            self.enableFaceID = false
            saveFaceIDPreference(false)
            showToast(.error("Face ID is not available on this device.", icon: "xmark.octagon.fill"))
        }
    }
    
    func confirmFaceIDSetupSuccess() {
        saveFaceIDPreference(true)
        self.enableFaceID = true
        self.navigateToFaceIDSetup = false
        
        showToast(.success("Face ID enabled successfully!"))
    }

    func confirmFaceIDDisableSuccess() {
        saveFaceIDPreference(false)
        self.enableFaceID = false
        self.navigateToFaceIDDisable = false
        
        showToast(.info("Face ID disabled.", icon: "lock.slash.fill"))
    }
    
    func handleFaceIDDisableDismissal() {
        self.enableFaceID = UserDefaults.standard.bool(forKey: Keys.faceID)
        self.navigateToFaceIDDisable = false
    }
    
    func handleFaceIDDismissal() {
        self.enableFaceID = UserDefaults.standard.bool(forKey: Keys.faceID)
        self.navigateToFaceIDSetup = false
    }
    
    private func saveFaceIDPreference(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Keys.faceID)
    }
}

extension MoreScreenViewModel {
    func handlePasscodeToggleChange(_ isEnabled: Bool) {
        self.enablePasscode = isEnabled
        
        if !isEnabled {
            guard !enableFaceID else {
                self.enablePasscode = true
                
                showToast(.warning("Please turn off Face ID first before disabling Passcode.", icon: "lock.trianglebadge.exclamationmark.fill"))
                return
            }
                        
            Task {
                try? await Task.sleep(for: .milliseconds(250))
                self.navigateToPasscodeDisable = true
            }
            return
        }
        
        Task {
            try? await Task.sleep(for: .milliseconds(250))
            self.navigateToPasscodeSetup = true
        }
    }
    
    func confirmPasscodeSetupSuccess() {
        savePasscodePreference(true)
        self.enablePasscode = true
        self.navigateToPasscodeSetup = false

        showToast(.success("Passcode enabled successfully!"))
    }
    
    func confirmPasscodeDisableSuccess() {
        removePasscodeFromKeychain()
        savePasscodePreference(false)
        self.enablePasscode = false
        self.navigateToPasscodeDisable = false
        
        showToast(.info("Passcode disabled.", icon: "lock.slash.fill"))
    }
    
    func handlePasscodeDisableDismissal() {
        self.enablePasscode = UserDefaults.standard.bool(forKey: Keys.passcode)
        self.navigateToPasscodeDisable = false
    }
    
    func handlePasscodeDismissal() {
        self.enablePasscode = UserDefaults.standard.bool(forKey: Keys.passcode)
        self.navigateToPasscodeSetup = false
    }
    
    private func savePasscodePreference(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Keys.passcode)
    }
    
    private func removePasscodeFromKeychain() {
        _ = KeychainHelper.deletePasscode()
    }
}

extension MoreScreenViewModel {
    
}
