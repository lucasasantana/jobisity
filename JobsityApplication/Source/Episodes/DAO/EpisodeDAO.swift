//
//  EpisodeDAO.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Foundation

protocol EpisodeDAO {
    func fetchAll(fromShowWithID showID: Int) async throws -> [Episode]
}
