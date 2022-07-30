//
//  NSLayoutConstraintsBuilder.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import UIKit

@resultBuilder
struct NSLayoutConstraintsBuilder {
    static func buildBlock(_ components: NSLayoutConstraint...) -> [NSLayoutConstraint] {
        components.map { $0 }
    }
}

extension NSLayoutConstraint {
    static func activate(@NSLayoutConstraintsBuilder constraintBuilder: () -> [NSLayoutConstraint]) {
        activate(constraintBuilder())
    }
}
