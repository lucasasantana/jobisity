//
//  ShowDetailViewController.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Combine
import UIKit

class ShowDetailViewModel {
    
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Cell>
    
    enum Section {
        case information
    }
    
    enum Cell {
        case info
        case summary
    }
    
    let show: Show
    
    @Published
    private(set) var snapshot: DataSourceSnapshot
    
    init(show: Show) {
        self.snapshot = DataSourceSnapshot()
        
        self.show = show
    }
    
    func configureInitialContent() {
        snapshot.appendSections([.information])
        snapshot.appendItems([.info, .summary], toSection: .information)
    }
}

class ShowDetailViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<ShowDetailViewModel.Section, ShowDetailViewModel.Cell>
    
    typealias ShowInformationCellRegistration = UICollectionView.CellRegistration<ShowInformationCell, ShowDetailViewModel.Cell>
    typealias ShowSummaryCellRegistration = UICollectionView.CellRegistration<ShowSummaryCell, ShowDetailViewModel.Cell>

    // MARK: Collection View configuration
    lazy var collectionView: UICollectionView = {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    lazy var showInformationCellRegistration: ShowInformationCellRegistration = {
        ShowInformationCellRegistration { [unowned self] cell, indexPath, _ in
            cell.setup(withShow: self.viewModel.show)
        }
    }()
    
    lazy var showSummaryCellRegistration: ShowSummaryCellRegistration = {
        ShowSummaryCellRegistration { [unowned self] cell, indexPath, _ in
            cell.setup(withShow: self.viewModel.show)
        }
    }()
    
    lazy var dataSource: DataSource = {
        let showInformationCellRegistration = showInformationCellRegistration
        let showSummaryCellRegistration = showSummaryCellRegistration
        let dataSource = DataSource(collectionView: collectionView) { [unowned self] collectionView, indexPath, cell in
            switch cell {
                case .info:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: showInformationCellRegistration,
                        for: indexPath,
                        item: cell
                    )
                case .summary:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: showSummaryCellRegistration,
                        for: indexPath,
                        item: cell
                    )
            }
        }
        
        return dataSource
    }()
    
    let viewModel: ShowDetailViewModel
    lazy var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ShowDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.$snapshot.sink { [weak self] snapshot in
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        }
        .store(in: &cancellables)
        viewModel.configureInitialContent()
    }
}
