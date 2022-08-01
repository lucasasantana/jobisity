//
//  AuthenticationKeychainDAO.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 01/08/22.
//

import Foundation
import LocalAuthentication

class AuthenticationKeychainDAO: AuthenticationDAO {
    
    static let shared = AuthenticationKeychainDAO()
    
    lazy var laContext = LAContext()
    
    @KeyChainBool(key: .isBiometryEnabled)
    var isBiometryEnabledKeychain: Bool?
    
    @KeyChainBool(key: .isPinSetup)
    var isPasswordSetupKeychain: Bool?
    
    @KeyChainString(key: .pinCode)
    var pinCode: String?
    
    var isBiometryAvailable: Bool {
        laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    var isBiometryEnabled: Bool {
        get {
            guard isBiometryAvailable else { return false }
            return isBiometryEnabledKeychain ?? false
        }
        set { isBiometryEnabledKeychain = newValue }
    }
    
    var isPasswordSetup: Bool {
        get { isPasswordSetupKeychain ?? false }
        set { isPasswordSetupKeychain = newValue }
    }
    
    func callBiometryAuthentication() async -> Bool {
        (try? await laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock your shows")) ?? false
    }
    
    func updatePassword(newValue: String) throws {
        guard !newValue.isEmpty else {
            throw AuthenticationDAOError.invalidPasswordFormat
        }
        
        isPasswordSetup = true
        pinCode = newValue
    }
    
    func validatePassword(value: String) -> Bool {
        value == pinCode
    }
    
    func setIsBiometryEnabled(_ newValue: Bool) {
        isBiometryEnabled = newValue
    }
}
