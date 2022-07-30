//
//  ShowListViewController.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Combine
import UIKit

class ShowListViewController: UICollectionViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<ShowListViewModel.Section, ShowCellViewModel>
    
    lazy var dataSource = makeDataSource()
    lazy var cancellables = Set<AnyCancellable>()
    
    let  viewModel: ShowListViewModel
    
    init(viewModel: ShowListViewModel) {
        self.viewModel = viewModel
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: listConfiguration))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.prefetchDataSource = self
        viewModel.$snapshot.sink { [weak self] snapshot in
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        }
        .store(in: &cancellables)
        viewModel.configureInitialContent()
    }
    
    // MARK: Data Source
    func makeShowCellRegistration() -> UICollectionView.CellRegistration<ShowCell, ShowCellViewModel> {
        return .init { cell, indexPath, cellViewModel in
            cell.setup(with: cellViewModel) { [weak self] in
                self?.viewModel.reloadItem(at: indexPath)
            }
        }
    }
    
    func makeDataSource() -> DataSource {
        let showCellRegistration = makeShowCellRegistration()
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, show in
            return collectionView.dequeueConfiguredReusableCell(using: showCellRegistration, for: indexPath, item: show)
        }
        
        return dataSource
    }
}

extension ShowListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.prefetchItems(at: indexPaths)
    }
}
