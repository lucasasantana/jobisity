//
//  ShowCellViewModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import UIKit

class ShowCellViewModel: Hashable {
    
    var showID: Int {
        show.id
    }
    
    var title: String {
        show.name
    }
    
    private var imageURL: URL {
        show.poster.medium
    }
    
    private(set) var poster: UIImage?
    
    private let imageDAO: ImageDAO
    
    let show: Show
    
    init(from show: Show, imageDAO: ImageDAO) {
        self.show = show
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
