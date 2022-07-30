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
    
    enum Section: Hashable {
        case information
        case season(Int)
    }
    
    enum Cell: Hashable {
        case info
        case summary
        case episode(Int)
    }
    
    let show: Show
    private var seasons: [Season]
    
    @Published
    private(set) var snapshot: DataSourceSnapshot
    
    private let episodesDAO: EpisodeDAO
    
    init(show: Show, episodesDAO: EpisodeDAO) {
        self.snapshot = DataSourceSnapshot()
        self.seasons = []
        
        self.show = show
        self.episodesDAO = episodesDAO
    }
    
    @MainActor
    func configureInitialContent() {
        snapshot.appendSections([.information])
        snapshot.appendItems([.info, .summary], toSection: .information)
        
        loadEpisodes()
    }
    
    @MainActor
    func loadEpisodes() {
        Task {
            let episodes = try await episodesDAO.fetchAll(fromShowWithID: show.id)
            seasons = EpisodesAdapter.groupEpisodesBySeason(episodes)
            
            let sections = seasons.map { Section.season($0.number) }
            snapshot.appendSections(sections)
            
            for season in seasons {
                let episodes = season.episodes.map { Cell.episode($0.id) }
                snapshot.appendItems(episodes, toSection: .season(season.number))
            }
        }
    }
    
    func episode(at indexPath: IndexPath) -> Episode {
        let season = indexPath.section - 1
        return seasons[season].episodes[indexPath.row]
    }
    
    func seasonNumber(at indexPath: IndexPath) -> Int {
        return indexPath.section - 1
    }
}

class ShowDetailViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<ShowDetailViewModel.Section, ShowDetailViewModel.Cell>
    
    typealias ShowInformationCellRegistration = UICollectionView.CellRegistration<ShowInformationCell, ShowDetailViewModel.Cell>
    typealias ShowSummaryCellRegistration = UICollectionView.CellRegistration<ShowSummaryCell, ShowDetailViewModel.Cell>
    typealias EpisodeCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ShowDetailViewModel.Cell>
    
    typealias SeasonHeaderRegistration = UICollectionView.SupplementaryRegistration<SeasonHeader>
    
    // MARK: Collection View configuration
    lazy var layout: UICollectionViewLayout = {
        var informationConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        informationConfiguration.showsSeparators = false
        
        var seasonConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        seasonConfiguration.headerMode = .supplementary
        
        return UICollectionViewCompositionalLayout { section, layoutEnviroment in
            guard section > .zero else  {
                return NSCollectionLayoutSection.list(using: informationConfiguration, layoutEnvironment: layoutEnviroment)
            }
            return NSCollectionLayoutSection.list(using: seasonConfiguration, layoutEnvironment: layoutEnviroment)
        }
    }()
    
    lazy var collectionView: UICollectionView = {
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
    
    lazy var episodeCellRegistration: EpisodeCellRegistration = {
        EpisodeCellRegistration { [unowned self] cell, indexPath, _ in
            var config = cell.defaultContentConfiguration()
            let episode = viewModel.episode(at: indexPath)
            config.text = episode.name
            cell.contentConfiguration = config
        }
    }()
    
    lazy var seasonHeaderRegistration: SeasonHeaderRegistration = {
        SeasonHeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) { [unowned self] (headerView, elementKind, indexPath) in
            if indexPath.section > .zero {
                headerView.setup(with: viewModel.seasonNumber(at: indexPath))
            }
        }
    }()
    
    lazy var dataSource: DataSource = {
        let showInformationCellRegistration = showInformationCellRegistration
        let showSummaryCellRegistration = showSummaryCellRegistration
        let espisodeCellRegistration = episodeCellRegistration
        
        let seasonHeaderRegistration = seasonHeaderRegistration
        
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
                case .episode:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: espisodeCellRegistration,
                        for: indexPath,
                        item: cell
                    )
            }
        }
        
        dataSource.supplementaryViewProvider = { [unowned self] (collectionView, _, indexPath) -> UICollectionReusableView? in
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: seasonHeaderRegistration,
                for: indexPath
            )
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
        viewModel
            .$snapshot
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
        viewModel.configureInitialContent()
    }
}
