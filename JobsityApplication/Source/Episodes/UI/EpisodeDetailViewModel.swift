//
//  EpisodeDetailViewModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 01/08/22.
//

import Foundation

class EpisodeDetailViewModel: EpisodeDetailViewModelProtocol {
    
    var title: String {
        episode.name
    }
    
    var seasonAndNumber: String {
        "Season \(episode.season), Episode \(episode.number)"
    }
    
    var posterURL: URL? {
        episode.poster?.medium
    }
    
    var summary: String? {
        episode.summary
    }
    
    private let episode: Episode
    
    init(episode: Episode) {
        self.episode = episode
    }
}
