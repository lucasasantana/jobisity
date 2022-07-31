//
//  HomeCoordinator.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import UIKit
import XCoordinator

class HomeCoordinator: TabBarCoordinator<HomeCoordinator.Tabs> {
    enum Tabs: Route {
        case shows
        case favorites
    }
    
    let showsCoordinator: ShowsCoordinator
    let favoritesCoordinator: ShowsCoordinator
    
    init() {
        let shows = ShowsCoordinator(mode: .home)
        self.showsCoordinator = shows
        
        let favorites = ShowsCoordinator(mode: .favorites)
        self.favoritesCoordinator = favorites
        
        super.init(tabs: [shows, favorites])
    }
    
    override func prepareTransition(for route: Tabs) -> TabBarTransition {
        switch route {
            case .shows:
                return .select(showsCoordinator)
            case .favorites:
                return .select(favoritesCoordinator)
        }
    }
}
