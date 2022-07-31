//
//  UserDefaultKeys.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import Foundation

extension UserDefaults {
    enum Keys: String {
        case favorites
    }
}

@propertyWrapper
struct UserDefault<Value> {
    let key: UserDefaults.Keys
    let defaultValue: Value
    var container: UserDefaults = .standard
    
    var wrappedValue: Value {
        get {
            return container.object(forKey: key.rawValue) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key.rawValue)
        }
    }
}
