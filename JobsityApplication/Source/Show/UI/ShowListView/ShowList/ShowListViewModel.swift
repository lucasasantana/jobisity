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
    private(set) var snapshot: DataSourceSnapshot
    private var cancellables: Set<AnyCancellable>
    
    private let router: UnownedRouter<ShowsCoordinator.Routes>
    
    init(showDAO: ShowDAO, imageDAO: ImageDAO, router: UnownedRouter<ShowsCoordinator.Routes>) {
        self.snapshot = DataSourceSnapshot()
        self.cancellables = Set()
        
        self.showDAO = showDAO
        self.imageDAO = imageDAO
        self.router = router
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
