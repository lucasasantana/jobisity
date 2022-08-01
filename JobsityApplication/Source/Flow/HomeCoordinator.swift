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
        case settings
    }
    
    let shows: Presentable
    let favorites: Presentable
    let settings: Presentable
    
    init() {
        let shows = ShowsCoordinator(mode: .home)
        self.shows = shows
        
        let favorites = ShowsCoordinator(mode: .favorites)
        self.favorites = favorites
        
        let settings = SettingsCoordinator()
        self.settings = settings
        
        super.init(tabs: [shows, favorites, settings])
    }
    
    override func prepareTransition(for route: Tabs) -> TabBarTransition {
        switch route {
            case .shows:
                return .select(shows)
            case .favorites:
                return .select(favorites)
            case .settings:
                return .select(settings)
        }
    }
}
