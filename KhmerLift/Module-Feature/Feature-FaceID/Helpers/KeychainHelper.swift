//
//  KeychainHelper.swift
//  KhmerLift
//
//  Created by Panha on 7/10/26.
//

import Foundation
import Security

public enum KeychainHelper {
    private static let passcodeKey = "user_app_passcode"
    
    public static func savePasscode(_ passcode: String) -> Bool {
        guard let data = passcode.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: passcodeKey,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    public static func getPasscode() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: passcodeKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    public static func deletePasscode() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: passcodeKey
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}
