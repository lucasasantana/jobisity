//
//  SettingsCoordinator.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import UIKit
import XCoordinator

class SettingsCoordinator: NavigationCoordinator<SettingsCoordinator.Routes> {
    
    enum Routes: Route {
        case settings
    }
    
    init() {
        super.init(initialRoute: .settings)
        self.setTabBarItem()
    }
    
    override func prepareTransition(for route: Routes) -> NavigationTransition {
        switch route {
            case .settings:
                return .push(SettingsView.makeController())
            
        }
    }
    
    
    func setTabBarItem() {
        rootViewController.tabBarItem.image = UIImage(systemName: "gearshape")
        rootViewController.tabBarItem.selectedImage = UIImage(systemName: "gearshape.fill")
        rootViewController.tabBarItem.title = "Settings"
    }
}

