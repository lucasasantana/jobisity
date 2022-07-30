//
//  ShowListViewModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Combine
import UIKit
import XCoordinator

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
    
    @Published
    private var indexesToReload: [IndexPath]
    
    @Published
    private(set) var snapshot: DataSourceSnapshot
    private var cancellables: Set<AnyCancellable>
    
    private let router: UnownedRouter<ShowsCoordinator.Routes>
    
    init(showDAO: ShowDAO, imageDAO: ImageDAO, router: UnownedRouter<ShowsCoordinator.Routes>) {
        self.snapshot = DataSourceSnapshot()
        self.indexesToReload = []
        self.cancellables = Set()
        
        self.showDAO = showDAO
        self.imageDAO = imageDAO
        self.router = router
        
        $indexesToReload
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .compactMap { [weak self] indexesToReload in
                guard let self = self else { return nil }
                let values = indexesToReload.map { indexPath -> ShowCellViewModel in
                    self.snapshot.itemIdentifiers[indexPath.row]
                }
                
                return !values.isEmpty ? Array(Set(values)) : nil
            }
            .sink { [weak self] (items: [ShowCellViewModel]) in
                self?.snapshot.reloadItems(items)
                self?.indexesToReload = []
            }
            .store(in: &cancellables)
    }
    
    @MainActor private func fetchContent() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                let shows = try await showDAO.fetchMany(page: page).map { show in
                    return ShowCellViewModel(from: show, imageDAO: imageDAO)
                }
                
                page += 1
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
    
    func reloadItem(at indexPath: IndexPath) {
        indexesToReload.append(indexPath)
    }
    
    @MainActor
    func configureInitialContent() {
        snapshot.appendSections([.showList])
        fetchContent()
    }
    
    @MainActor
    func prefetchItems(at indexes: [IndexPath]) {
        indexes.forEach { indexPath in
            guard indexPath.row < snapshot.itemIdentifiers.count else { return }
            let item = snapshot.itemIdentifiers[indexPath.row]
            Task {
                guard item.poster == nil else { return }
                await item.loadPoster()
                reloadItem(at: indexPath)
            }
        }
        
        if let last = indexes.last?.row, last > snapshot.itemIdentifiers.count - 50 {
            fetchContent()
        }
    }
}
