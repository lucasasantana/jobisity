//
//  EpisodeNetworkDAO.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Foundation

class EpisodeNetworkDAO: EpisodeDAO {
    
    let manager: NetworkManager
    let baseURL: URL
    
    init(manager: NetworkManager = NetworkManager()) {
        self.manager = manager
        self.baseURL = URL(string: "https://api.tvmaze.com")!
    }
    
    func fetchAll(fromShowWithID showID: Int) async throws -> [Episode] {
        let request = EpisodeListRequestModel(baseURL: baseURL, showID: showID)
        return try await manager.request(with: request)
    }
}
