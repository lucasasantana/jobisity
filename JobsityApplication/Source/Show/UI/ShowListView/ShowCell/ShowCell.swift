//
//  ShowCell.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import UIKit

class ShowCellContentView: UIView, UIContentView {
    
    var configuration: UIContentConfiguration {
        didSet {
            apply(configuration: configuration)
        }
    }
    
    lazy var posterView: AsyncImage = {
        let imageView = AsyncImage()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    lazy var rootStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()
    
    init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ShowCellContentView: ViewCodable {
    func setupViewHierarchy() {
        addSubview(rootStackView)
        
        rootStackView.addArrangedSubview(posterView)
        rootStackView.addArrangedSubview(titleLabel)
    }
    
    func setupConstraints() {
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
                
        NSLayoutConstraint.activate {
            rootStackView.heightAnchor.constraint(equalToConstant: 150)
            posterView.widthAnchor.constraint(equalToConstant: 107)
            
            rootStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)
            rootStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
            rootStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
            rootStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
        }
    }
    
    func apply(configuration: UIContentConfiguration) {
        guard let showCellConfig = configuration as? ShowCellConfiguration else {
            return
        }
        
        titleLabel.text = showCellConfig.title
        posterView.imageURL = showCellConfig.posterURL
    }
}

struct ShowCellConfiguration: UIContentConfiguration {
    
    let title: String
    let posterURL: URL?
    
    func makeContentView() -> UIView & UIContentView {
        ShowCellContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> ShowCellConfiguration {
        return self
    }
}

class ShowCell: UICollectionViewListCell {
    
    func setup(with viewModel: ShowCellViewModel) {
        let config = ShowCellConfiguration(
            title: viewModel.title,
            posterURL: viewModel.poster
        )
        
        contentConfiguration = config
        accessories = [.disclosureIndicator()]
    }
}
