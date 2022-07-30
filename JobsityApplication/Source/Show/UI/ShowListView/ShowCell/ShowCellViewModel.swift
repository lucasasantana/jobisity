//
//  ShowCellViewModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import UIKit

class ShowCellViewModel: Hashable {
    
    let showID: Int
    let title: String
    
    private(set) var poster: UIImage?
    private(set) var placeholderImage: UIImage?
    
    private let imageURL: URL
    private let imageDAO: ImageDAO
    
    init(from show: Show, imageDAO: ImageDAO) {
        self.showID = show.id
        self.title = show.name
        self.imageURL = show.poster.medium
        self.imageDAO = imageDAO
        
        self.poster = imageDAO.loadFromCache(imageID: "\(showID)-medium")
    }
    
    func loadPoster() async {
        do {
            poster = try await imageDAO.fetch(imageWithURL: imageURL, imageID: "\(showID)-medium")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(showID)
    }
    
    static func == (lhs: ShowCellViewModel, rhs: ShowCellViewModel) -> Bool {
        lhs.showID == rhs.showID
    }
}
