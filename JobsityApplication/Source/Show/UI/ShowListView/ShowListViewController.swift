//
//  ShowListViewController.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Combine
import Kingfisher
import UIKit

class ShowCellViewModel: Hashable {
    
    let showID: Int
    
    let title: String
    
    private(set) var poster: UIImage?
    private(set) var placeholderImage: UIImage?
    
    private let imageURL: URL
    
    init(from show: Show) {
        self.showID = show.id
        self.title = show.name
        self.imageURL = show.poster.medium
    }
    
    func loadPoster() async {
        let imageDAO = ImageKingfisherDAO()
        do {
            poster = try await imageDAO.fetch(imageWithURL: imageURL)
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(showID)
    }
    
    static func == (lhs: ShowCellViewModel, rhs: ShowCellViewModel) -> Bool {
        lhs.showID == rhs.showID
    }
}

@MainActor
class ShowListViewModel {
    
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ShowCellViewModel>
    
    enum Section {
        case showList
    }
   
    private var page: Int = 1
    private let showDAO: ShowDAO
    
    @Published
    private var indexesToReload: [IndexPath]
    
    @Published
    private(set) var snapshot: DataSourceSnapshot
    private var cancellables: Set<AnyCancellable>
    
    init() {
        snapshot = DataSourceSnapshot()
        showDAO = ShowNetworkDAO()
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
        Task {
            do {
                let shows = try await showDAO.fetchMany(page: page).map { show in
                    return ShowCellViewModel(from: show)
                }
                page += 1
                snapshot.appendItems(shows, toSection: .showList)
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
            let item = snapshot.itemIdentifiers[indexPath.row]
            Task {
                guard item.poster == nil else { return }
                await item.loadPoster()
                reloadItem(at: indexPath)
            }
        }
    }
}

class ShowListViewController: UICollectionViewController {
    
    lazy var dataSource = makeDataSource()
    lazy var viewModel = ShowListViewModel()
    
    lazy var cancellables = Set<AnyCancellable>()
    
    convenience init() {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        self.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: listConfiguration))
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
    
    func makeShowCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, ShowCellViewModel> {
        return .init { cell, indexPath, cellViewModel in
            var config = cell.defaultContentConfiguration()
            config.text = cellViewModel.title
            config.imageProperties.maximumSize = CGSize(width: 150, height: 150)
            
            if let image = cellViewModel.poster {
                config.image = image
                cell.accessories = []
            } else {
            
                let activityIndicator = UIActivityIndicatorView()
                activityIndicator.style = .large
                activityIndicator.startAnimating()
                
                let cellAcessory = UICellAccessory.CustomViewConfiguration(customView: activityIndicator, placement: .leading(displayed: .always))
                
                cell.accessories = [.customView(configuration: cellAcessory)]
                
                Task {
                    await cellViewModel.loadPoster()
                    self.viewModel.reloadItem(at: indexPath)
                }
            }
            
            cell.contentConfiguration = config
        }
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<ShowListViewModel.Section, ShowCellViewModel> {
        let showCellRegistration = makeShowCellRegistration()
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, show in
            return collectionView.dequeueConfiguredReusableCell(using: showCellRegistration, for: indexPath, item: show)
        }
    }
}

extension ShowListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.prefetchItems(at: indexPaths)
    }
}
