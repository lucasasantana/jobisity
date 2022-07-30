//
//  ShowCell.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import UIKit

class ShowCell: UICollectionViewListCell {
    
    lazy var loadingPlaceholder: UIView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.startAnimating()
        
        return activityIndicator
    }()
    
    func setup(with viewModel: ShowCellViewModel, reloadItem: @escaping () -> Void) {
        var config = defaultContentConfiguration()
        config.text = viewModel.title
        config.imageProperties.maximumSize = CGSize(width: 150, height: 150)
        
        if let image = viewModel.poster {
            accessories = []
            config.image = image
            
        } else {
            let cellAcessory = UICellAccessory.CustomViewConfiguration(
                customView: loadingPlaceholder,
                placement: .leading(displayed: .always)
            )
            
            accessories = [.customView(configuration: cellAcessory)]
            
            Task {
                await viewModel.loadPoster()
                reloadItem()
            }
        }
        
        contentConfiguration = config
    }
}
