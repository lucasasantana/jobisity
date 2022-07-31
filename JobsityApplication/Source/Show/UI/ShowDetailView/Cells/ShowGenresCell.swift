//
//  ShowGenresCell.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import Combine
import UIKit

class ShowGenresCellContentView: UIView, UIContentView {
    
    enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 8
    }
    
    var configuration: UIContentConfiguration {
        didSet {
            apply(configuration: configuration)
        }
    }
    
    // MARK: Stacks
    lazy var rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()
    
    // MARK: Labels
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    lazy var genresLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    init(configuration: ShowGenresCellContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupView()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func apply(configuration: UIContentConfiguration) {
        guard let showGenresConfig = configuration as? ShowGenresCellContentConfiguration else {
            return
        }
        
        titleLabel.text = "Genres"
        genresLabel.text = showGenresConfig.genres.reduce(into: String(), { partialResult, nextValue in
            if partialResult.isEmpty {
                partialResult = nextValue
            } else {
                partialResult = "\(partialResult), \(nextValue)"
            }
        })
    }
}

extension ShowGenresCellContentView: ViewCodable {
    
    func setupViewHierarchy() {
        
        addSubview(rootStackView)
        
        rootStackView.addArrangedSubview(titleLabel)
        rootStackView.addArrangedSubview(genresLabel)
    }
    
    func setupConstraints() {
        
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        genresLabel.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate {
            rootStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding)
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalPadding)
            rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding)
            rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding)
        }
    }
}

struct ShowGenresCellContentConfiguration: UIContentConfiguration {
    
    let genres: [String]
    
    func makeContentView() -> UIView & UIContentView {
        return ShowGenresCellContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}

class ShowGenresCell: UICollectionViewListCell {
    func setup(withShow show: Show) {
        let config = ShowGenresCellContentConfiguration(
            genres: show.genres
        )
        contentConfiguration = config
    }
}


