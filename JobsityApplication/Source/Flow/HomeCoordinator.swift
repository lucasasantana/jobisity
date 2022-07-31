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
    }
    
    let showsCoordinator: ShowsCoordinator
    
    init() {
        let shows = ShowsCoordinator(isSeachEnabled: true)
        self.showsCoordinator = shows
        super.init(tabs: [shows])
    }
    
    override func prepareTransition(for route: Tabs) -> TabBarTransition {
        switch route {
            case .shows:
                return .select(showsCoordinator)
        }
    }
}
