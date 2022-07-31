//
//  SeasonHeader.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import UIKit

class EpisodesHeader: UICollectionReusableView {
    
    lazy var rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func setup() {
        titleLabel.text = "Episodes"
        backgroundColor = .systemBackground
    }
}

extension EpisodesHeader: ViewCodable {
    
    func setupViewHierarchy() {
        addSubview(rootStackView)
        rootStackView.addArrangedSubview(titleLabel)
    }
    
    func setupConstraints() {
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate {
            rootStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
            rootStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
            rootStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 16)
            rootStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -16)
        }
    }
}
