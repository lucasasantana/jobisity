//
//  AuthenticationDAO.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 01/08/22.
//

import Foundation

enum AuthenticationDAOError: Error {
    case invalidPasswordFormat
}

protocol AuthenticationDAO {
    var isPasswordSetup: Bool { get }
    
    func updatePassword(newValue: String) throws
    func validatePassword(value: String) -> Bool
}
