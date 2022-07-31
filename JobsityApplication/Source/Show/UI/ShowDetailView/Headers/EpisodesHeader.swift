//
//  SeasonHeader.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import UIKit

class EpisodesHeader: UICollectionReusableView {
    
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
        addSubview(titleLabel)
    }
    
    func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate {
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 16)
            titleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -16)
        }
    }
}
