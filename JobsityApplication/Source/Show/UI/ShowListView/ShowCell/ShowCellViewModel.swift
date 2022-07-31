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
    
    var poster: URL? {
        show.poster?.medium
    }
    
    let show: Show
    
    init(from show: Show) {
        self.show = show
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(showID)
    }
    
    static func == (lhs: ShowCellViewModel, rhs: ShowCellViewModel) -> Bool {
        lhs.showID == rhs.showID
    }
}
