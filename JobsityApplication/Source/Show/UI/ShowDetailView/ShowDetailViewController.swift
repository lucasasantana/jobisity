//
//  ShowDetailViewController.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Combine
import UIKit

protocol ShowDetailViewModelProtocol {
    var episodesSectionSnapshotPublisher: AnyPublisher<ShowDetailSectionSnapshot, Never> { get }
    var isFavoritePublisher: AnyPublisher<Bool, Never> { get }
    var isFavorite: Bool { get }
    var sceneTitle: String { get }
    var show: Show { get }
    
    func loadInitialContent() -> ShowDetailDataSourceSnapshot
    func toogleFavorite()
    func shouldSelect(at: IndexPath) -> Bool
    func handleCellSelection(cell: ShowDetailCell)
}

class ShowDetailViewController: UICollectionViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<ShowDetailSection, ShowDetailCell>
    
    typealias ShowInformationCellRegistration = UICollectionView.CellRegistration<ShowInformationCell, ShowDetailCell>
    typealias ShowSummaryCellRegistration = UICollectionView.CellRegistration<ShowSummaryCell, ShowDetailCell>
    typealias ShowGenreCellRegistration = UICollectionView.CellRegistration<ShowGenresCell, ShowDetailCell>
    typealias EpisodeCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ShowDetailCell>
    typealias SeasonCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ShowDetailCell>
    
    typealias EpisodesHeaderRegistration = UICollectionView.SupplementaryRegistration<EpisodesHeader>
    
    // MARK: Collection View configuration
    lazy var layout: UICollectionViewLayout = {
        var informationConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        informationConfiguration.showsSeparators = false
        
        var seasonConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        seasonConfiguration.headerMode = .supplementary
        
        let layout = UICollectionViewCompositionalLayout { section, layoutEnviroment in
            guard section > .zero else  {
                return NSCollectionLayoutSection.list(using: informationConfiguration, layoutEnvironment: layoutEnviroment)
            }
            return NSCollectionLayoutSection.list(using: seasonConfiguration, layoutEnvironment: layoutEnviroment)
        }
        
        return layout
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
    
    lazy var showGenresCellRegistration: ShowGenreCellRegistration = {
        ShowGenreCellRegistration { [unowned self] cell, indexPath, _ in
            cell.setup(withShow: self.viewModel.show)
        }
    }()
    
    lazy var episodeCellRegistration: EpisodeCellRegistration = {
        EpisodeCellRegistration { [unowned self] cell, indexPath, item in
            guard case let ShowDetailCell.episode(episode) = item else {
                return
            }
            
            var config = cell.defaultContentConfiguration()
            config.text = episode.name
            cell.contentConfiguration = config
            cell.accessories = [.disclosureIndicator()]
        }
    }()
    
    lazy var seasonCellRegistration: SeasonCellRegistration = {
        SeasonCellRegistration { [unowned self] cell, _, season in
            guard case let ShowDetailCell.season(value) = season else {
                return
            }
            
            var config = cell.defaultContentConfiguration()
            config.textProperties.font = .boldSystemFont(ofSize: 24)
            config.text = "Season \(value)"
            
            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options: headerDisclosureOption)]
            
            cell.contentConfiguration = config
        }
    }()
    
    lazy var episodesHeaderRegistration: EpisodesHeaderRegistration = {
        EpisodesHeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] (headerView, elementKind, indexPath) in
            headerView.setup()
        }
    }()
    
    lazy var dataSource: DataSource = {
        let showInformationCellRegistration = showInformationCellRegistration
        let showSummaryCellRegistration = showSummaryCellRegistration
        let showGenresCellRegistration = showGenresCellRegistration
        let espisodeCellRegistration = episodeCellRegistration
        let seasonCellRegistration = seasonCellRegistration
        
        let episodesHeaderRegistration = episodesHeaderRegistration
        
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
                case .genres:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: showGenresCellRegistration,
                        for: indexPath,
                        item: cell
                    )
                case .season:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: seasonCellRegistration,
                        for: indexPath,
                        item: cell
                    )
                case .episode:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: episodeCellRegistration,
                        for: indexPath,
                        item: cell
                    )
            }
        }
        
        dataSource.supplementaryViewProvider = { [unowned self] (collectionView, _, indexPath) -> UICollectionReusableView? in
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: episodesHeaderRegistration,
                for: indexPath
            )
        }
        
        return dataSource
    }()
    
    let viewModel: ShowDetailViewModelProtocol
    lazy var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ShowDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        collectionView.collectionViewLayout = layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel
            .episodesSectionSnapshotPublisher
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, to: .episodes)
            }
            .store(in: &cancellables)
        
        dataSource.apply(viewModel.loadInitialContent())
        configureNavigation()
    }
    
    func configureNavigation() {
        navigationItem.backButtonTitle = viewModel.sceneTitle
        navigationItem.largeTitleDisplayMode = .never
        
        let imageProvider: (Bool) -> UIImage? = { isFavorite in
            if isFavorite {
                return UIImage(systemName: "star.slash.fill")
            } else {
                return UIImage(systemName: "star")
            }
        }
        
        let button = UIBarButtonItem(image: imageProvider(viewModel.isFavorite), style: .plain, target: self, action: #selector(handleBookmark))
        navigationItem.rightBarButtonItem = button
        
        viewModel
            .isFavoritePublisher
            .map { imageProvider($0) }
            .sink { [weak self] image in
                self?.navigationItem.rightBarButtonItem?.image = image
            }
            .store(in: &cancellables)
    }
    
    @objc
    func handleBookmark() {
        viewModel.toogleFavorite()
    }
}

extension ShowDetailViewController {
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        viewModel.shouldSelect(at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        viewModel.handleCellSelection(cell: item)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (cell as? ShowInformationCell) != nil {
            self.title = nil
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (cell as? ShowInformationCell) != nil {
            self.title = self.viewModel.sceneTitle
        }
    }
}
