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
    typealias ShowCellRegistration = UICollectionView.CellRegistration<ShowCell, ShowCellViewModel>
    
    // MARK: Collection View DataSource configuration
    
    lazy var cellRegistration: ShowCellRegistration = {
        ShowCellRegistration { cell, indexPath, cellViewModel in
            cell.setup(with: cellViewModel)
        }
    }()
    
    lazy var dataSource: DataSource = {
        let showCellRegistration = cellRegistration
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, show in
            return collectionView.dequeueConfiguredReusableCell(using: showCellRegistration, for: indexPath, item: show)
        }
        
        return dataSource
    }()
    
    // MARK: Collection View configuration
    
    let viewModel: ShowListViewModel
    lazy var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ShowListViewModel) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.title = viewModel.sceneTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        configureCollection()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.$snapshot.sink { [weak self] snapshot in
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        }
        .store(in: &cancellables)
        viewModel.configureInitialContent()
    }
    
    func configureCollection() {
        let listConfiguration = UICollectionLayoutListConfiguration.init(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        
        collectionView.prefetchDataSource = self
        collectionView.collectionViewLayout = layout
    }
}

extension ShowListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.prefetchItems(at: indexPaths)
    }
}

extension ShowListViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.handleItemSelected(at: indexPath)
    }
}
