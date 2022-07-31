//
//  FavoritesShowsListViewModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import Combine
import Foundation
import XCoordinator

class FavoritesShowsListViewModel: ShowListViewModelProtocol {
    
    var sceneTitle: String {
        "Favorites"
    }
    
    var isSearchEnabled: Bool {
        false
    }
    
    var snapshotPublisher: AnyPublisher<ShowListDataSourceSnapshot, Never> {
        $snapshot.eraseToAnyPublisher()
    }
    
    @Published
    private(set) var snapshot: ShowListDataSourceSnapshot
    
    private var isLoading: Bool = false
    
    private let showDAO: ShowDAO
    private var shows: [ShowCellViewModel]
    private let router: UnownedRouter<ShowsCoordinator.Routes>
    
    private var cancellables: Set<AnyCancellable>
    
    init(showDAO: ShowDAO, router: UnownedRouter<ShowsCoordinator.Routes>) {
        self.snapshot = ShowListDataSourceSnapshot()
        self.shows = []
        self.cancellables = Set()
        
        self.showDAO = showDAO
        self.router = router
    }
    
    func configureInitialContent() {
        snapshot.appendSections([.showList])
        reloadContentIfNeeded()
    }
    
    func reloadContentIfNeeded() {
        Task {
            await fetchContent()
        }
    }
    
    @MainActor
    private func fetchContent() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                defer { isLoading = false }
                let shows = try await showDAO.loadFavorites()
                    .sorted { $0.name.lowercased() < $1.name.lowercased() }
                    .map { show in
                        return ShowCellViewModel(from: show)
                    }
                
                guard shows != self.shows else { return }
                self.snapshot.deleteItems(self.shows)
                self.snapshot.appendItems(shows)
                self.shows = shows
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    }
    
    func prefetchItems(at indexes: [IndexPath]) {
        /* Not impelemented */
    }
    
    func handleItemSelected(at indexPath: IndexPath) {
        guard indexPath.row < snapshot.itemIdentifiers.count else { return }
        let item = snapshot.itemIdentifiers[indexPath.row]
        router.trigger(.showDetail(item.show))
    }
    
    func handleSearch(searchText: String?, isSearchActive: Bool) {
        /* Not impelemented */
    }
}
