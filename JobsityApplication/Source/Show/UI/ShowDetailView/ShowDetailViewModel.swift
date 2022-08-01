//
//  ShowDetailViewModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Combine
import UIKit
import XCoordinator

typealias ShowDetailDataSourceSnapshot = NSDiffableDataSourceSnapshot<ShowDetailSection, ShowDetailCell>
typealias ShowDetailSectionSnapshot = NSDiffableDataSourceSectionSnapshot<ShowDetailCell>

enum ShowDetailSection: Hashable {
    case information
    case episodes
}

enum ShowDetailCell: Hashable {
    case info
    case summary
    case genres
    case season(Int)
    case episode(Episode)
}

class ShowDetailViewModel: ShowDetailViewModelProtocol {
    
    var sceneTitle: String {
        show.name
    }
    
    @Published
    private(set) var isFavorite: Bool
    
    var isFavoritePublisher: AnyPublisher<Bool, Never> {
        $isFavorite.eraseToAnyPublisher()
    }
    
    let show: Show
    private var seasons: [Season]
    
    var episodesSectionSnapshotPublisher: AnyPublisher<ShowDetailSectionSnapshot, Never> {
        return episodesSectionSnapshotSubject.eraseToAnyPublisher()
    }
    
    private let episodesSectionSnapshotSubject: PassthroughSubject<ShowDetailSectionSnapshot, Never>
    
    private let showDAO: ShowDAO
    private let episodesDAO: EpisodeDAO
    private let router: UnownedRouter<ShowsCoordinator.Routes>
    
    private var cancellables: Set<AnyCancellable>
    
    init(show: Show, showDAO: ShowDAO, episodesDAO: EpisodeDAO, router: UnownedRouter<ShowsCoordinator.Routes>) {
        self.episodesSectionSnapshotSubject = PassthroughSubject()
        self.seasons = []
        self.cancellables = Set()
        self.isFavorite = showDAO.isFavorite(show)
        
        self.show = show
        self.router = router
        self.showDAO = showDAO
        self.episodesDAO = episodesDAO
    }
    
    func toogleFavorite() {
        if isFavorite {
            showDAO.removeFromFavorites(show: show)
        } else {
            showDAO.markAsFavorite(show: show)
        }
    }
    
    @MainActor
    func loadInitialContent() -> ShowDetailDataSourceSnapshot {
        var snapshot = ShowDetailDataSourceSnapshot()
        snapshot.appendSections([.information, .episodes])
        snapshot.appendItems([.info, .summary, .genres], toSection: .information)
        
        loadEpisodes()
        
        showDAO
            .favoritesDidChange
            .compactMap { [weak self] () -> Bool? in
                guard let self = self else { return nil }
                return self.showDAO.isFavorite(self.show)
            }
            .sink { [weak self] (isFavorite: Bool) in
                guard let self = self else { return }
                self.isFavorite = isFavorite
            }
            .store(in: &cancellables)
        
        
        return snapshot
    }
    
    @MainActor
    func loadEpisodes() {
        Task {
            let episodes = try await episodesDAO.fetchAll(fromShowWithID: show.id)
            seasons = EpisodesAdapter.groupEpisodesBySeason(episodes)
            
            let seasonItems = seasons.map { ShowDetailCell.season($0.number) }
            
            var sectionSnapshot = ShowDetailSectionSnapshot()
            sectionSnapshot.append(seasonItems)
            
            for season in seasons {
                let episodes = season.episodes.map { ShowDetailCell.episode($0) }
                sectionSnapshot.append(episodes, to: .season(season.number))
            }
            
            episodesSectionSnapshotSubject.send(sectionSnapshot)
        }
    }
    
    func shouldSelect(at index: IndexPath) -> Bool {
        return index.section > .zero
    }
    
    func handleCellSelection(cell: ShowDetailCell) {
        guard case let ShowDetailCell.episode(episode) = cell else {
            return
        }
        
        router.trigger(.episodeDetail(episode))
    }
}

