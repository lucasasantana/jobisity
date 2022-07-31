//
//  ShowListViewModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Combine
import UIKit
import XCoordinator

extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>,Publishers.SetFailureType<Self, Error>> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}

class ShowListViewModel {
    
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ShowCellViewModel>
    
    enum Section {
        case showList
    }
    
    private var page: Int = 1
    private let showDAO: ShowDAO
    private let imageDAO: ImageDAO
    
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
    private(set) var snapshot: DataSourceSnapshot
   
    
    private let router: UnownedRouter<ShowsCoordinator.Routes>
    
    init(isSearchEnabled: Bool, showDAO: ShowDAO, imageDAO: ImageDAO, router: UnownedRouter<ShowsCoordinator.Routes>) {
        self.snapshot = DataSourceSnapshot()
        self.shows = []
        self.searchedShows = []
        
        self.showDAO = showDAO
        self.imageDAO = imageDAO
        self.router = router
        self.isSearchEnabled = isSearchEnabled
    }
    
    @MainActor private func fetchContent() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                let shows = try await showDAO.fetchMany(page: page).map { show in
                    return ShowCellViewModel(from: show)
                }
                
                page += 1
                self.shows.append(contentsOf: shows)
                snapshot.appendItems(shows, toSection: .showList)
                isLoading = false
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    }
}

extension ShowListViewModel {
    
    func handleItemSelected(at indexPath: IndexPath) {
        guard indexPath.row < snapshot.itemIdentifiers.count else { return }
        let item = snapshot.itemIdentifiers[indexPath.row]
        router.trigger(.showDetail(item.show))
    }
    
    func beginSearch() {
        searchCancellable = $searchText
            .debounce(for: 0.2, scheduler: DispatchQueue.main)
            .compactMap { [weak self] value in
                guard let value = value, !value.isEmpty else {
                    self?.snapshot.deleteItems(self?.snapshot.itemIdentifiers ?? [])
                    self?.snapshot.appendItems(self?.shows ?? [], toSection: .showList)
                    return nil
                }

                return value
            }
            .asyncMap { [weak self] (text: String) async throws -> [Show] in
                guard let self = self else { return  [] }
                return try await self.showDAO.searchMany(query: text)
            }
            .catch { error in
                Just([])
            }
            .compactMap { shows -> [ShowCellViewModel]? in
                return shows.map { ShowCellViewModel(from: $0)}
            }
            .sink(receiveValue: { [weak self] result in
                self?.snapshot.deleteItems(self?.snapshot.itemIdentifiers ?? [])
                self?.snapshot.appendItems(result, toSection: .showList)
            })
    }
    
    func handleSearch(searchText: String?) {
        guard self.searchText != searchText else { return }
        if searchCancellable == nil {
            beginSearch()
        }
        self.searchText = searchText
    }
    
    @MainActor
    func configureInitialContent() {
        snapshot.appendSections([.showList])
        fetchContent()
    }
    
    @MainActor
    func prefetchItems(at indexes: [IndexPath]) {
        if let last = indexes.last?.row, last > snapshot.itemIdentifiers.count - 50 {
            fetchContent()
        }
    }
}
