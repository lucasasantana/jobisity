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
    
    lazy var rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 32
        return stackView
    }()
    
    lazy var headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
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
        
        titleLabel.text = showInformationConfig.title
        summaryLabel.setHTMLFromString(htmlText: showInformationConfig.summary)
        
        let imageResource = ImageResource(downloadURL: showInformationConfig.imageURL)
        posterImageView.kf.setImage(with: imageResource)
    }
}

extension ShowInformationCellContentView: ViewCodable {
    
    func setupViewHierarchy() {
        
        addSubview(rootStackView)
        
        rootStackView.addArrangedSubview(headerStackView)
        rootStackView.addArrangedSubview(summaryLabel)
        
        headerStackView.addArrangedSubview(posterImageView)
        headerStackView.addArrangedSubview(titleLabel)
    }
    
    func setupConstraints() {
        
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        
        posterImageView.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
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
    
    var title: String
    var imageURL: URL
    
    var summary: String?
    
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
            summary: show.summary
        )
        contentConfiguration = config
    }
}
