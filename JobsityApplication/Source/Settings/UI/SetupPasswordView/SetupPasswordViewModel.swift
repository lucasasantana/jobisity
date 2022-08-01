//
//  SetupPasswordViewModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 01/08/22.
//

import Combine
import SwiftUI

class SetupPasswordViewModel: ObservableObject {
    
    @Published
    var newPassword = ""
    
    @Published
    var isBiomeryEnabled = false
    
    var isPasswordSetup: Bool {
        authenticationDAO.isPasswordSetup
    }
    
    @Published
    var isErrorDisplayed = false
    
    var pinCodeSetupTitle: String {
        if isPasswordSetup {
            return "Update your pin code"
        } else {
            return "Configure your pin code"
        }
    }
    
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
            objectWillChange.send()
        } catch {
            isErrorDisplayed = true
        }
    }
}
