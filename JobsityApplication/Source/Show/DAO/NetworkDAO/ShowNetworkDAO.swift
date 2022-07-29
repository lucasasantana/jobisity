//
//  ShowNetworkDAO.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

class ShowNetworkDAO: ShowDAO {
    
    let manager: NetworkManager
    let baseURL: URL
    
    init(manager: NetworkManager = NetworkManager()) {
        self.manager = manager
        self.baseURL = URL(string: "https://api.tvmaze.com")!
    }
    
    func fetchMany(page: Int?) async throws -> [Show] {
        let request = ShowListRequestModel(baseURL: baseURL, page: page)
        return try await manager.request(with: request)
    }
}
