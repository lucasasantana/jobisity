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
    typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<Cell>
    
    enum Section: Hashable {
        case information
        case episodes
    }
    
    enum Cell: Hashable {
        case info
        case summary
        case season(Int)
        case episode(Episode)
    }
    
    let show: Show
    private var seasons: [Season]
    
    var episodesSectionSnapshotPublisher: AnyPublisher<SectionSnapshot, Never> {
        return episodesSectionSnapshotSubject.eraseToAnyPublisher()
    }
    
    private let episodesSectionSnapshotSubject: PassthroughSubject<SectionSnapshot, Never>
    
    private let episodesDAO: EpisodeDAO
    
    init(show: Show, episodesDAO: EpisodeDAO) {
        self.episodesSectionSnapshotSubject = PassthroughSubject()
        self.seasons = []
        
        self.show = show
        self.episodesDAO = episodesDAO
    }
    
    @MainActor
    func configureInitialContent() -> DataSourceSnapshot {
        var snapshot = DataSourceSnapshot()
        snapshot.appendSections([.information, .episodes])
        snapshot.appendItems([.info, .summary], toSection: .information)
        
        loadEpisodes()
        
        return snapshot
    }
    
    @MainActor
    func loadEpisodes() {
        Task {
            let episodes = try await episodesDAO.fetchAll(fromShowWithID: show.id)
            seasons = EpisodesAdapter.groupEpisodesBySeason(episodes)
                        
            let seasonItems = seasons.map { Cell.season($0.number) }
            
            var sectionSnapshot = SectionSnapshot()
            sectionSnapshot.append(seasonItems)
            
            for season in seasons {
                let episodes = season.episodes.map { Cell.episode($0) }
                sectionSnapshot.append(episodes, to: .season(season.number))
            }
                
            episodesSectionSnapshotSubject.send(sectionSnapshot)
        }
    }
    
    func seasonNumber(at indexPath: IndexPath) -> Int {
        return indexPath.section
    }
}

class ShowDetailViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<ShowDetailViewModel.Section, ShowDetailViewModel.Cell>
    
    typealias ShowInformationCellRegistration = UICollectionView.CellRegistration<ShowInformationCell, ShowDetailViewModel.Cell>
    typealias ShowSummaryCellRegistration = UICollectionView.CellRegistration<ShowSummaryCell, ShowDetailViewModel.Cell>
    typealias EpisodeCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ShowDetailViewModel.Cell>
    typealias SeasonCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, ShowDetailViewModel.Cell>
    
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
        EpisodeCellRegistration { [unowned self] cell, indexPath, item in
            guard case let ShowDetailViewModel.Cell.episode(episode) = item else {
                return
            }
            
            var config = cell.defaultContentConfiguration()
            config.text = episode.name
            cell.contentConfiguration = config
        }
    }()
    
    lazy var seasonCellRegistration: SeasonCellRegistration = {
        SeasonCellRegistration { [unowned self] cell, _, season in
            guard case let ShowDetailViewModel.Cell.season(value) = season else {
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
            .episodesSectionSnapshotPublisher
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot, to: .episodes)
            }
            .store(in: &cancellables)

        dataSource.apply(viewModel.configureInitialContent())
    }
}
