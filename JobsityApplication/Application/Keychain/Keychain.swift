//
//  Keychain.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 01/08/22.
//

import Foundation
import KeychainSwift

extension KeychainSwift {
    static let shared = KeychainSwift()
}

enum KeychainKeys: String {
    case isPinSetup
    case pinCode
}

@propertyWrapper
struct KeyChainString {
    let key: KeychainKeys
    var container: KeychainSwift = .shared
    
    var wrappedValue: String? {
        get {
            return container.get(key.rawValue)
        }
        set {
            if let newValue = newValue {
                container.set(newValue, forKey: key.rawValue)
            } else {
                container.delete(key.rawValue)
            }
        }
    }
}

@propertyWrapper
struct KeyChainBool {
    let key: KeychainKeys
    var container: KeychainSwift = .shared
    
    var wrappedValue: Bool? {
        get {
            return container.getBool(key.rawValue)
        }
        set {
            if let newValue = newValue {
                container.set(newValue, forKey: key.rawValue)
            } else {
                container.delete(key.rawValue)
            }
        }
    }
}
