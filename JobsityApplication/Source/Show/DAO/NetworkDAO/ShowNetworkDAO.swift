//
//  ShowNetworkDAO.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

struct ShowResult: Decodable {
    let score: Double
    let show: Show
}

class ShowNetworkDAO: ShowDAO {
    
    let manager: NetworkManager
    let baseURL: URL
    
    init(manager: NetworkManager = NetworkManager()) {
        self.manager = manager
        self.baseURL = URL(string: "https://api.tvmaze.com")!
    }
    
    func searchMany(query: String) async throws -> [Show] {
        let request = ShowSearchRequestModel(baseURL: baseURL, query: query)
        return try await manager.request(with: request).map { $0.show }
    }
    
    func fetchMany(page: Int?) async throws -> [Show] {
        let request = ShowListRequestModel(baseURL: baseURL, page: page)
        return try await manager.request(with: request)
    }
}
