//
//  AuthenticationKeychainDAO.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 01/08/22.
//

import Foundation

class AuthenticationKeychainDAO: AuthenticationDAO {
    
    static let shared = AuthenticationKeychainDAO()
    
    @KeyChainBool(key: .isPinSetup)
    var isPasswordSetupKeychain: Bool?
    
    @KeyChainString(key: .pinCode)
    var pinCode: String?
    
    var isPasswordSetup: Bool {
        get { isPasswordSetupKeychain ?? false }
        set { isPasswordSetupKeychain = newValue }
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
}
