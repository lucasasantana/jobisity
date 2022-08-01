//
//  ShowListViewModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Combine
import UIKit
import XCoordinator

class HomeShowListViewModel: ShowListViewModelProtocol {
    
    private var page: Int = 1
    private let showDAO: ShowDAO
    
    let sceneTitle = "Shows"
    
    private(set) var isLoading = false
    private(set) var isSearchEnabled: Bool
    
    
    private var shows: [ShowCellViewModel]
    
    // Search
    private var isSearchActive: Bool = false
    
    @Published
    private var searchText: String?
    private var searchedShows: [Show]
    private var searchCancellable: AnyCancellable?
    
    @Published
    private(set) var snapshot: ShowListDataSourceSnapshot

    private let router: UnownedRouter<ShowsCoordinator.Routes>
    
    var snapshotPublisher: AnyPublisher<ShowListDataSourceSnapshot, Never> {
        $snapshot.eraseToAnyPublisher()
    }
    
    init(isSearchEnabled: Bool, showDAO: ShowDAO, router: UnownedRouter<ShowsCoordinator.Routes>) {
        self.snapshot = ShowListDataSourceSnapshot()
        self.shows = []
        self.searchedShows = []
        
        self.showDAO = showDAO
        self.router = router
        self.isSearchEnabled = isSearchEnabled
    }
    
    func reloadContentIfNeeded() {
        /* Not implemented */
    }
    
    @MainActor
    private func fetchContent() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                let fetchedShows = try await showDAO.fetchMany(page: page).map { show in
                    return ShowCellViewModel(from: show)
                }
                
                page += 1
                shows.append(contentsOf: fetchedShows)
                snapshot.appendItems(fetchedShows, toSection: .showList)
                isLoading = false
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    }
}

extension HomeShowListViewModel {
    
    func handleItemSelected(at indexPath: IndexPath) {
        guard indexPath.row < snapshot.itemIdentifiers.count else { return }
        let item = snapshot.itemIdentifiers[indexPath.row]
        router.trigger(.showDetail(item.show))
    }
    
    func beginSearch() {
        isSearchActive = true
        searchCancellable = $searchText
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .compactMap { [weak self] value in
                guard let value = value, !value.isEmpty else {
                    self?.snapshot.deleteItems(self?.snapshot.itemIdentifiers ?? [])
                    self?.snapshot.appendItems(self?.shows ?? [], toSection: .showList)
                    return nil
                }

                return value
            }
            .asyncMap { [weak self] (text: String) async throws -> [Show]? in
                return try await self?.showDAO.searchMany(query: text)
            }
            .catch { _ in
                Just([])
            }
            .compactMap { shows -> [ShowCellViewModel]? in
                return shows?.map { ShowCellViewModel(from: $0)}
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                self?.snapshot.deleteItems(self?.snapshot.itemIdentifiers ?? [])
                self?.snapshot.appendItems(result, toSection: .showList)
            })
    }
    
    func endSearch() {
        isSearchActive = false
        searchCancellable = nil
        snapshot.deleteItems(snapshot.itemIdentifiers)
        snapshot.appendItems(shows, toSection: .showList)
    }
    
    func handleSearch(searchText: String?, isSearchActive: Bool) {
        if !self.isSearchActive && isSearchActive {
            beginSearch()
        } else if self.isSearchActive && !isSearchActive {
            endSearch()
        }
        
        guard isSearchActive, self.searchText != searchText else { return }
        self.searchText = searchText
    }
    
    @MainActor
    func configureInitialContent() {
        snapshot.appendSections([.showList])
        fetchContent()
    }
    
    @MainActor
    func prefetchItems(at indexes: [IndexPath]) {
        if !isSearchActive, let last = indexes.last?.row, last > snapshot.itemIdentifiers.count - 50 {
            fetchContent()
        }
    }
}
