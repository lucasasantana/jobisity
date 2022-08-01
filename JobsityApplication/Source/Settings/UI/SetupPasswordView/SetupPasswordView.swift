//
//  SetupPasswordView.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import SwiftUI

struct SetupPasswordView: View {

    @ObservedObject
    var viewModel = SetupPasswordViewModel()
    
    @State
    var isUpdatingPassword: Bool = false
    
    @ViewBuilder
    var passwordSetup: some View {
        VStack(spacing: 16) {
            SecureField("Please enter your new password", text: $viewModel.newPassword)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 16))
            
            if !viewModel.newPassword.isEmpty {
                Button {
                    endEditing()
                    viewModel.setupPassword()
                    isUpdatingPassword = false
                } label: {
                    Text("Update password")
                }
            }
        }
        .frame(maxWidth: 375)
        .alert(isPresented: $viewModel.isErrorDisplayed) { // 4
            Alert(
                title: Text("Invalid password"),
                message: Text("Please enter a valid password")
            )
        }.padding()
    }
    
    var body: some View {
        Form {
            Section {
                NavigationLink(isActive: $isUpdatingPassword) {
                    passwordSetup
                } label: {
                    Text(viewModel.pinCodeSetupTitle)
                }
                
                if viewModel.isPasswordSetup {
                    Toggle(isOn: viewModel.isBiometryEnabled) {
                        Text("Use biometry")
                    }
                }
            }
        }
        .navigationTitle("Password settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SetupPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SetupPasswordView()
        }
    }
}
