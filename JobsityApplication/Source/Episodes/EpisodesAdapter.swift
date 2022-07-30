//
//  EpisodesAdapter.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Foundation

struct Season {
    let number: Int
    let episodes: [Episode]
    
    func appending(episode: Episode) -> Season {
        Season(number: number, episodes: episodes + [episode])
    }
}

struct EpisodesAdapter {
    static func groupEpisodesBySeason(_ episodes: [Episode]) -> [Season] {
        var seasons: [Int: Season] = [:]
        
        for episode in episodes {
            let season = seasons[episode.season, default: Season(number: episode.season, episodes: [])]
            seasons[episode.season] = season.appending(episode: episode)
        }
        
        return seasons
            .keys
            .sorted()
            .compactMap { seasons[$0] }
    }
}
