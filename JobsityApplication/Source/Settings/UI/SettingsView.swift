//
//  SettingsView.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import SwiftUI

struct SettingsView: View {
    
    static func makeController() -> UIViewController {
        return UIHostingController(rootView: SettingsView())
    }
    
    var body: some View {
        List {
            Section {
                NavigationLink {
                    SetupPasswordView()
                } label: {
                    Text("Password settings")
                        
                }
                .buttonStyle(.plain)
            }
        }
        .navigationBarTitle("Settings")
        .navigationBarTitleDisplayMode(.automatic)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
