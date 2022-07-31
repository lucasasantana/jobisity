//
//  ShowListViewController.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Combine
import UIKit

typealias ShowListDataSourceSnapshot = NSDiffableDataSourceSnapshot<ShowListSection, ShowCellViewModel>

enum ShowListSection {
    case showList
}

protocol ShowListViewModelProtocol {
    var sceneTitle: String { get }
    var isSearchEnabled: Bool { get }
    var snapshotPublisher: AnyPublisher<ShowListDataSourceSnapshot, Never> { get }
    
    func configureInitialContent()
    func reloadContentIfNeeded()
    func prefetchItems(at indexes: [IndexPath])
    func handleItemSelected(at indexPath: IndexPath)
    func handleSearch(searchText: String?, isSearchActive: Bool)
}

class ShowListViewController: UICollectionViewController {
    
    lazy var seachController = UISearchController()
    
    typealias DataSource = UICollectionViewDiffableDataSource<ShowListSection, ShowCellViewModel>
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
    
    let viewModel: ShowListViewModelProtocol
    lazy var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ShowListViewModelProtocol) {
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
        viewModel.snapshotPublisher.sink { [weak self] snapshot in
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        }
        .store(in: &cancellables)
        viewModel.configureInitialContent()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if viewModel.isSearchEnabled {
            navigationItem.searchController = seachController
            seachController.searchResultsUpdater = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadContentIfNeeded()
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

extension ShowListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.handleSearch(
            searchText: searchController.searchBar.text,
            isSearchActive: searchController.isActive
        )
    }
}
