//
//  SetupPasswordViewModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 01/08/22.
//

import Combine

class SetupPasswordViewModel: ObservableObject {
    
    @Published
    var newPassword = ""
    
    @Published
    var isBiomeryEnabled = false
    
    @Published
    var isPasswordSetup = false
    
    @Published
    var isErrorDisplayed = false
    
    let authenticationDAO: AuthenticationDAO
    
    init(authenticationDAO: AuthenticationDAO = AuthenticationKeychainDAO.shared) {
        self.authenticationDAO = authenticationDAO
    }
    
    func setupPassword() {
        guard !newPassword.isEmpty else {
            isErrorDisplayed = true
            return
        }
        
        do {
            try authenticationDAO.updatePassword(newValue: newPassword)
        } catch {
            isErrorDisplayed = true
        }
    }
}
