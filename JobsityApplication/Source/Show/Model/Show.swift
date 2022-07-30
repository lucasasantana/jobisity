//
//  Show.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

struct Poster: Decodable, Hashable {
    let medium: URL
    let original: URL
}

struct Schedule: Decodable {
    
    enum Day: String, Codable {
        case friday = "Friday"
        case monday = "Monday"
        case saturday = "Saturday"
        case sunday = "Sunday"
        case thursday = "Thursday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
    }
    
    enum CodingKeys: String, CodingKey {
        case time
        case days
    }
    
    let time: String
    let days: [Day]
}

struct Show {
    let id: Int
    let name: String
    let poster: Poster
    
    let genres: [String]
    let schedule: Schedule
    
    let summary: String
}

extension Show: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case poster = "image"
        case genres
        case schedule
        case summary
    }
}

extension Show: Equatable {
    static func == (lhs: Show, rhs: Show) -> Bool {
        lhs.id == rhs.id
    }
}
