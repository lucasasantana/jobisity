//
//  ShowsCoordinator.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Foundation
import XCoordinator
import UIKit

class ShowsCoordinator: NavigationCoordinator<ShowsCoordinator.Routes> {
    
    enum Routes: Route {
        case showList
        case showDetail(Show)
    }
    
    init(rootViewController: RootViewController) {
        super.init(rootViewController: rootViewController, initialRoute: .showList)
    }
    
    override func prepareTransition(for route: Routes) -> NavigationTransition {
        switch route {
            case .showList:
                let viewModel = ShowListViewModel(showDAO: ShowNetworkDAO(), imageDAO: ImageKingfisherDAO(), router: unownedRouter)
                let showListController = ShowListViewController(viewModel: viewModel)
                return .push(showListController)
            case .showDetail:
                return .push(UIViewController())
        }
    }
}
