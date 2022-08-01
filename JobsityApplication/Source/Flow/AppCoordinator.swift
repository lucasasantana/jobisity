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
        case auth
    }
    
    lazy var home: Presentable = HomeCoordinator()
    lazy var authentication: Presentable = {
        let viewModel = AuthenticationViewModel(router: self)
        return AuthenticationViewController(viewModel: viewModel)
    }()
    
    init() {
        if AuthenticationKeychainDAO.shared.isPasswordSetup {
            super.init(initialRoute: .auth)
        } else {
            super.init(initialRoute: .content)
        }
    }
    
    override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        switch route {
            case .content:
                return .presentFullScreen(home)
            case .auth:
                return .presentFullScreen(authentication)
        }
    }
}

extension AppCoordinator: AuthenticationCoordinator {
    func loadContent() {
        trigger(.content)
    }
}
