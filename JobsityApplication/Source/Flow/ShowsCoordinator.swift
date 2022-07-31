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
    
    enum Mode {
        case home
        case favorites
    }
    
    enum Routes: Route {
        case showList
        case showDetail(Show)
        case episodeDetail(Episode)
    }
    
    let mode: Mode
    let isSeachEnabled: Bool
    
    lazy var showDAO = ShowNetworkDAO.shared
    
    init(isSeachEnabled: Bool = true, mode: Mode) {
        self.isSeachEnabled = isSeachEnabled
        self.mode = mode
        super.init(initialRoute: .showList)
        self.setTabBarItem()
    }
    
    override func prepareTransition(for route: Routes) -> NavigationTransition {
        switch route {
            case .showList:
                return .push(ShowListViewController(viewModel: showListViewModel()))
            case let .showDetail(show):
                let viewModel = ShowDetailViewModel(show: show, showDAO: showDAO, episodesDAO: EpisodeNetworkDAO(), router: unownedRouter)
                return .push(ShowDetailViewController(viewModel: viewModel))
            case let .episodeDetail(episode):
                let viewModel = EpisodeDetailViewModel(episode: episode)
                return .push(EpisodeDetailViewController(viewModel: viewModel))
        }
    }
    
    func showListViewModel() -> ShowListViewModelProtocol {
        switch mode {
            case .home:
                return HomeShowListViewModel(
                    isSearchEnabled: isSeachEnabled,
                    showDAO: showDAO,
                    router: unownedRouter
                )
            case .favorites:
                return FavoritesShowsListViewModel(showDAO: showDAO, router: unownedRouter)
        }
    }
    
    func setTabBarItem() {
        switch mode {
            case .home:
                rootViewController.tabBarItem.image = UIImage(systemName: "house")
                rootViewController.tabBarItem.selectedImage = UIImage(systemName: "house.fill")
            case .favorites:
                rootViewController.tabBarItem.image = UIImage(systemName: "star")
                rootViewController.tabBarItem.selectedImage = UIImage(systemName: "star.fill")
        }
    }
}
