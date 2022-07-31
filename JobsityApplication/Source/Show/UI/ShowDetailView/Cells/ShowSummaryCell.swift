//
//  ShowSummaryCell.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Combine
import UIKit

class ShowSummaryCellContentView: UIView, UIContentView {
    
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
        stackView.spacing = 16
        return stackView
    }()
    
    // MARK: Labels
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    lazy var summaryLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = .zero
        return label
    }()
    
    init(configuration: ShowSummaryCellContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupView()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func apply(configuration: UIContentConfiguration) {
        guard let showInformationConfig = configuration as? ShowSummaryCellContentConfiguration else {
            return
        }
        
        titleLabel.text = "Summary"
        summaryLabel.setHTMLFromString(htmlText: showInformationConfig.summary)
    }
}

extension ShowSummaryCellContentView: ViewCodable {
    
    func setupViewHierarchy() {
        
        addSubview(rootStackView)
        
        rootStackView.addArrangedSubview(titleLabel)
        rootStackView.addArrangedSubview(summaryLabel)
    }
    
    func setupConstraints() {
        
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        summaryLabel.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate {
            rootStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding)
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalPadding)
            rootStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding)
            rootStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding)
        }
    }
}

struct ShowSummaryCellContentConfiguration: UIContentConfiguration {
    
    let summary: String?
    
    func makeContentView() -> UIView & UIContentView {
        return ShowSummaryCellContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}

class ShowSummaryCell: UICollectionViewListCell {
    func setup(withShow show: Show) {
        let config = ShowSummaryCellContentConfiguration(
            summary: show.summary
        )
        contentConfiguration = config
    }
}

