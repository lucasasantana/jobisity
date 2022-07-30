//
//  ImageDAO.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation
import Kingfisher
import UIKit

protocol ImageDAO {
    func loadFromCache(imageID: String) -> UIImage?
    func fetch(imageWithURL url: URL, imageID: String?) async throws -> UIImage
}


class ImageKingfisherDAO: ImageDAO {
    
    let manager: KingfisherManager
    
    init(manager: KingfisherManager = .shared) {
        self.manager = manager
    }
    
    
    func loadFromCache(imageID: String) -> UIImage? {
        ImageCache.default.retrieveImageInMemoryCache(forKey: imageID)
    }
    
    func fetch(imageWithURL url: URL, imageID: String?) async throws -> UIImage {
        let resource = ImageResource(downloadURL: url, cacheKey: imageID)
        return try await withCheckedThrowingContinuation({ continuation in
            manager.retrieveImage(with: resource) { result in
                continuation.resume(with: result)
            }
        })
        .image
    }
}
