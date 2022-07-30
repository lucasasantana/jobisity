//
//  ShowListViewModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Combine
import UIKit

@MainActor
class ShowListViewModel {
    
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ShowCellViewModel>
    
    enum Section {
        case showList
    }
    
    private var page: Int = 1
    private let showDAO: ShowDAO
    private let imageDAO: ImageDAO
    
    private(set) var isLoading = false
    
    @Published
    private var indexesToReload: [IndexPath]
    
    @Published
    private(set) var snapshot: DataSourceSnapshot
    private var cancellables: Set<AnyCancellable>
    
    init() {
        snapshot = DataSourceSnapshot()
        showDAO = ShowNetworkDAO()
        imageDAO = ImageKingfisherDAO()
        
        indexesToReload = []
        cancellables = Set()
        
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
    
    func configureInitialContent() {
        snapshot.appendSections([.showList])
        fetchContent()
    }
    
    func fetchContent() {
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
    
    func reloadItem(at indexPath: IndexPath) {
        indexesToReload.append(indexPath)
    }
    
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
