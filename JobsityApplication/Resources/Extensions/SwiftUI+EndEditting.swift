//
//  SwiftUI+EndEditting.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 01/08/22.
//

import SwiftUI

extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
