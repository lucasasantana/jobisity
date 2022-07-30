//
//  AppCoordinator.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Foundation

import XCoordinator

class AppCoordinator: NavigationCoordinator<AppCoordinator.AppRoute> {
    
    enum AppRoute: Route {
        case content
    }
    
    init() {
        super.init(initialRoute: .content)
    }
    
    override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        switch route {
            case .content:
                addChild(ShowsCoordinator(rootViewController: rootViewController))
                return .none()
        }
    }
}
