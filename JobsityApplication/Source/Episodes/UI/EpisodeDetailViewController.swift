//
//  EpisodeDetailViewController.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import UIKit
import Kingfisher

class EpisodeDetailViewModel {
    
    var title: String {
        episode.name
    }
    
    var seasonAndNumber: String {
        "Season \(episode.season), Episode \(episode.number)"
    }
    
    var posterURL: URL? {
        episode.poster?.medium
    }
    
    var summary: String? {
        episode.summary
    }
   
    private let episode: Episode
    
    init(episode: Episode) {
        self.episode = episode
    }
}

class EpisodeDetailViewController: UIViewController {
    
    enum Constants {
        static let horizontalPadding: CGFloat = 24
    }
    
    let viewModel: EpisodeDetailViewModel
    
    lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        return UIView(frame: .zero)
    }()
    
    lazy var rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 32
        return stack
    }()
    
    lazy var posterImageView: AsyncImage = {
        let imageView = AsyncImage()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var episodeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.title
        label.numberOfLines = .zero
        return label
    }()
    
    lazy var seasonAndNumberLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.seasonAndNumber
        label.numberOfLines = 1
        return label
    }()
    
    lazy var sumaryLabel: UILabel = {
        let label = UILabel()
        label.setHTMLFromString(htmlText: viewModel.summary)
        label.numberOfLines = .zero
        return label
    }()
    
    init(viewModel: EpisodeDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAppearance()
        navigationItem.largeTitleDisplayMode = .never
    }
}

extension EpisodeDetailViewController: ViewCodable  {
    func setupViewHierarchy() {
        view.addSubview(contentScrollView)
        
        contentScrollView.addSubview(contentView)
        contentView.addSubview(rootStackView)
        
        rootStackView.addArrangedSubview(episodeTitleLabel)
        rootStackView.addArrangedSubview(seasonAndNumberLabel)
        rootStackView.addArrangedSubview(posterImageView)
        rootStackView.addArrangedSubview(sumaryLabel)
        
        rootStackView.setCustomSpacing(4, after: episodeTitleLabel)
    }
    
    func setupConstraints() {
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        posterImageView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate {
            
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            contentScrollView.topAnchor.constraint(equalTo: view.topAnchor)
            contentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
            contentView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor)
            contentView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor)
            contentView.topAnchor.constraint(equalTo: contentScrollView.topAnchor)
            contentView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor)
            
            rootStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding)
            rootStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding)
            rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32)
            rootStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
            
            posterImageView.heightAnchor.constraint(equalToConstant: 140)
        }
    }
    
    func setupAppearance() {
        
        view.backgroundColor = .systemBackground
        
        episodeTitleLabel.font = .boldSystemFont(ofSize: 24)
        seasonAndNumberLabel.font = .systemFont(ofSize: 16)
        
        if let imageURL = viewModel.posterURL {
            posterImageView.imageURL = imageURL
        } else {
            posterImageView.isHidden = true
        }
    }
}
