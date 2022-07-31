//
//  ShowInformationCell.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Combine
import UIKit
import Kingfisher

class ShowInformationCellContentView: UIView, UIContentView {
    
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 8
        
        static let horizontalSpacing: CGFloat = 16
    }
    
    var configuration: UIContentConfiguration {
        didSet {
            apply(configuration: configuration)
        }
    }
    
    // MARK: Stacks
    lazy var rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var informationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    // MARK: Images
    lazy var posterImageView: AsyncImage = {
        let imageView = AsyncImage()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    // MARK: Labels
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 2
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    lazy var daysLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    lazy var summaryLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = .zero
        return label
    }()
    
    init(configuration: ShowInformationCellContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupView()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func apply(configuration: UIContentConfiguration) {
        guard let showInformationConfig = configuration as? ShowInformationCellContentConfiguration else {
            return
        }
        
        // Labels
        titleLabel.text = showInformationConfig.title
        timeLabel.text = showInformationConfig.time
        daysLabel.text = showInformationConfig.days.reduce(into: String(), { partialResult, nextValue in
            if partialResult.isEmpty {
                partialResult = nextValue
            } else {
                partialResult = "\(partialResult) | \(nextValue)"
            }
        })
        
        // Poster
        posterImageView.imageURL = showInformationConfig.imageURL
    }
}

extension ShowInformationCellContentView: ViewCodable {
    
    func setupViewHierarchy() {
        
        addSubview(rootStackView)
                
        rootStackView.addArrangedSubview(posterImageView)
        rootStackView.addArrangedSubview(informationStackView)
        
        informationStackView.addArrangedSubview(titleLabel)
        informationStackView.addArrangedSubview(timeLabel)
        informationStackView.addArrangedSubview(daysLabel)
        
        informationStackView.spacing = 2.0
        informationStackView.setCustomSpacing(4.0, after: timeLabel)
    }
    
    func setupConstraints() {
        
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        
        posterImageView.setContentHuggingPriority(.required, for: .horizontal)
        posterImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
                
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        daysLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        timeLabel.setContentHuggingPriority(.required, for: .vertical)
        daysLabel.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate {
            rootStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding)
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalPadding)
            rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding)
            rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding)
            
            posterImageView.heightAnchor.constraint(equalToConstant: 150)
            posterImageView.widthAnchor.constraint(equalTo: posterImageView.heightAnchor, multiplier: 0.7)
        }
    }
}

struct ShowInformationCellContentConfiguration: UIContentConfiguration {
    
    let title: String
    let imageURL: URL
        
    let days: [String]
    let time: String
    
    func makeContentView() -> UIView & UIContentView {
        return ShowInformationCellContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}

class ShowInformationCell: UICollectionViewListCell {
    func setup(withShow show: Show) {
        let config = ShowInformationCellContentConfiguration(
            title: show.name,
            imageURL: show.poster.medium,
            days: show.schedule.days.map { $0.rawValue },
            time: show.schedule.time
        )
        contentConfiguration = config
    }
}
