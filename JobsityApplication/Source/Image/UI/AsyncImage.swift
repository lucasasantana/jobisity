//
//  AsyncImage.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import UIKit
import Kingfisher
import SkeletonView

class AsyncImage: UIImageView {
    
    var imageURL: URL? {
        didSet {
            loadContent()
        }
    }

    init() {
        super.init(frame: .zero)
        loadContent()
        isSkeletonable = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadContent() {
        guard let imageURL = imageURL else {
            hideSkeleton()
            return
        }

        showSkeleton()
        
        let imageResource = ImageResource(downloadURL: imageURL)
        kf.setImage(with: imageResource) { [weak self] result in
            self?.hideSkeleton()
        }
    }
}

