//
//  ViewCodable.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import UIKit

protocol ViewCodable {
    
    func setupView()
    
    func setupViewHierarchy()
    func setupConstraints()
}

extension ViewCodable {
    func setupView() {
        setupViewHierarchy()
        setupConstraints()
    }
}
