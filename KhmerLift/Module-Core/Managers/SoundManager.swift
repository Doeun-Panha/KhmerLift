//
//  SoundManager.swift
//  KhmerLift
//
//  Created by Panha on 8/10/26.
//

import Foundation
import AudioToolbox

enum ToastType {
    case success
    case warning
    case error
}


final class SoundManager {
    static let shared = SoundManager()
    
    private init() {}
    
    func playSound(for type: ToastType) {
        let soundID: SystemSoundID
        
        switch type {
        case .success:
            soundID = 1054
            
        case .warning:
            soundID = 1007
            
        case .error:
            soundID = 1053
        }
        
        AudioServicesPlaySystemSound(soundID)
    }
}
