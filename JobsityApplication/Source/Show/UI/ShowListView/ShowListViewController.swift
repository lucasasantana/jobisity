//
//  ShowListViewController.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import UIKit

class ShowListViewController: UICollectionViewController {
    
    enum Section {
        case showList
    }
    
    lazy var dataSource = makeDataSource()
    
    convenience init() {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        self.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: listConfiguration))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
                
        Task {
            await applyInitialSnapshot()
        }
    }
    
    func makeShowCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Show> {
        return .init { cell, _, show in
            var config = cell.defaultContentConfiguration()
            config.text = show.name
            cell.contentConfiguration = config
        }
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Show> {
        let showCellRegistration = makeShowCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, show in
            return collectionView.dequeueConfiguredReusableCell(using: showCellRegistration, for: indexPath, item: show)
        }
    }
    
    func applyInitialSnapshot() async {
        guard let shows = try? await ShowNetworkDAO().fetchMany(page: 1) else { return }
        var snapshot = NSDiffableDataSourceSnapshot<Section, Show>()
        snapshot.appendSections([.showList])
        snapshot.appendItems(shows, toSection: .showList)
        dataSource.apply(snapshot)
    }
}
