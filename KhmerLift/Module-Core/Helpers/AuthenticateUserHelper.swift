////
////  AuthenticateUserHelper.swift
////  KhmerLift
////
////  Created by Panha on 25/9/26.
////
//
//import LocalAuthentication
//
//func authenticateUser() {
//    let context = LAContext()
//    var error: NSError?
//    
//    // 1. Check if biometrics are available
//    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//        
//        // 2. Perform authentication
//        let reason = "Log in to your account"
//        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
//            DispatchQueue.main.async {
//                if success {
//                    // 3. Check if Face ID state changed (e.g., second face added)
//                    let currentDomainState: Data?
//                    if #available(iOS 18.0, *) {
//                        currentDomainState = context.domainState
//                    } else {
//                        currentDomainState = context.evaluatedPolicyDomainState
//                    }
//                    if let currentDomainState = context.evaluatedPolicyDomainState {
//                        let savedDomainState = UserDefaults.standard.data(forKey: "savedBiometricState") // Ideally store in Keychain
//                        
//                        if savedDomainState == nil {
//                            // First time setup - save current domain state
//                            UserDefaults.standard.set(currentDomainState, forKey: "savedBiometricState")
//                            print("Biometric state saved.")
//                        } else if savedDomainState != currentDomainState {
//                            // State changed! A second face was added or biometrics were re-enrolled
//                            print("Biometric enrollment changed! Invalidating biometric session.")
//                            
//                            // Action: Require account password and update saved state after successful login
//                            promptForPasswordAndResetBiometrics(newDomainState: currentDomainState)
//                            return
//                        }
//                    }
//                    
//                    print("Successfully authenticated without biometric state changes.")
//                } else {
//                    print("Authentication failed: \(authError?.localizedDescription ?? "")")
//                }
//            }
//        }
//    }
//}
//
//func promptForPasswordAndResetBiometrics(newDomainState: Data) {
//    // Force user to log in with account password before accepting the new Face ID state
//    // Once password is verified:
//    UserDefaults.standard.set(newDomainState, forKey: "savedBiometricState")
//}
