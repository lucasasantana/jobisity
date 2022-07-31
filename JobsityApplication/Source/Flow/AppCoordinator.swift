//
//  AppCoordinator.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Foundation
import XCoordinator

extension Transition {
    
    static func presentFullScreen(_ presentable: Presentable, animation: Animation? = nil) -> Transition {
        presentable.viewController?.modalPresentationStyle = .fullScreen
        return .present(presentable, animation: animation)
    }
}

class AppCoordinator: NavigationCoordinator<AppCoordinator.AppRoute> {
    
    enum AppRoute: Route {
        case content
    }
    
    lazy var homeCoordinator = HomeCoordinator()
    
    init() {
        super.init(initialRoute: .content)
    }
    
    override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        switch route {
            case .content:
                return .presentFullScreen(homeCoordinator)
        }
    }
}
