//
//  Show.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

struct ShowPoster: Decodable, Hashable {
    let medium: URL
    let original: URL
}

struct Show: Decodable, Hashable, Equatable {
    
    let id: Int
    let name: String
    let poster: ShowPoster
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try values.decode(Int.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.poster = try values.decode(ShowPoster.self, forKey: .image)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Show, rhs: Show) -> Bool {
        lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case image = "image"
    }
}
