//
//  Episode.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Foundation

struct Episode: Hashable {
    
    let id: Int
    
    let season: Int
    let number: Int
    
    let name: String
    let poster: Poster?
    
    let summary: String?
}

extension Episode: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case season
        case number
        case poster = "image"
        case summary
    }
}
