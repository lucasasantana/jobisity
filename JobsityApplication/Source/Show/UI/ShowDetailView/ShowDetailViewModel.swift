//
//  ShowDetailViewModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Combine
import UIKit
import XCoordinator

class ShowDetailViewModel {
    
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Cell>
    typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<Cell>
    
    enum Section: Hashable {
        case information
        case episodes
    }
    
    enum Cell: Hashable {
        case info
        case summary
        case season(Int)
        case episode(Episode)
    }
    
    let show: Show
    private var seasons: [Season]
    
    var episodesSectionSnapshotPublisher: AnyPublisher<SectionSnapshot, Never> {
        return episodesSectionSnapshotSubject.eraseToAnyPublisher()
    }
    
    private let episodesSectionSnapshotSubject: PassthroughSubject<SectionSnapshot, Never>
    
    private let episodesDAO: EpisodeDAO
    private let router: UnownedRouter<ShowsCoordinator.Routes>
    
    init(show: Show, episodesDAO: EpisodeDAO, router: UnownedRouter<ShowsCoordinator.Routes>) {
        self.episodesSectionSnapshotSubject = PassthroughSubject()
        self.seasons = []
        
        self.show = show
        self.router = router
        self.episodesDAO = episodesDAO
    }
    
    @MainActor
    func configureInitialContent() -> DataSourceSnapshot {
        var snapshot = DataSourceSnapshot()
        snapshot.appendSections([.information, .episodes])
        snapshot.appendItems([.info, .summary], toSection: .information)
        
        loadEpisodes()
        
        return snapshot
    }
    
    @MainActor
    func loadEpisodes() {
        Task {
            let episodes = try await episodesDAO.fetchAll(fromShowWithID: show.id)
            seasons = EpisodesAdapter.groupEpisodesBySeason(episodes)
            
            let seasonItems = seasons.map { Cell.season($0.number) }
            
            var sectionSnapshot = SectionSnapshot()
            sectionSnapshot.append(seasonItems)
            
            for season in seasons {
                let episodes = season.episodes.map { Cell.episode($0) }
                sectionSnapshot.append(episodes, to: .season(season.number))
            }
            
            episodesSectionSnapshotSubject.send(sectionSnapshot)
        }
    }
    
    func shouldSelect(at index: IndexPath) -> Bool {
        return index.section > .zero
    }
    
    func handleCellSelection(cell: Cell) {
        guard case let Cell.episode(episode) = cell else {
            return
        }
        
        router.trigger(.episodeDetail(episode))
    }
}
