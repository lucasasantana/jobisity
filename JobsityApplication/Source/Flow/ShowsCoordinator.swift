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
        case episodeDetail(Episode)
    }
    
    init(rootViewController: RootViewController) {
        super.init(rootViewController: rootViewController, initialRoute: .showList)
    }
    
    override func prepareTransition(for route: Routes) -> NavigationTransition {
        switch route {
            case .showList:
                let viewModel = ShowListViewModel(showDAO: ShowNetworkDAO(), imageDAO: ImageKingfisherDAO(), router: unownedRouter)
                return .push(ShowListViewController(viewModel: viewModel))
            case let .showDetail(show):
                let viewModel = ShowDetailViewModel(show: show, episodesDAO: EpisodeNetworkDAO(), router: unownedRouter)
                return .push(ShowDetailViewController(viewModel: viewModel))
            case let .episodeDetail(episode):
                let viewModel = EpisodeDetailViewModel(episode: episode)
                return .push(EpisodeDetailViewController(viewModel: viewModel))
        }
    }
}
