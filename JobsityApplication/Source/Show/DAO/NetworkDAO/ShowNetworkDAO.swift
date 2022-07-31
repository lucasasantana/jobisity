//
//  ShowNetworkDAO.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Combine
import Foundation

class ShowNetworkDAO: ShowDAO {
    
    static let shared: ShowNetworkDAO = ShowNetworkDAO()
    
    let favoritesSubject: PassthroughSubject<Void, Never>
    
    let manager: NetworkManager
    let baseURL: URL
    
    @UserDefault(key: .favorites, defaultValue: [])
    var favoritesShowsIDs: [Int]
    
    var favoritesDidChange: AnyPublisher<Void, Never> {
        favoritesSubject.eraseToAnyPublisher()
    }
    
    init(manager: NetworkManager = NetworkManager()) {
        self.manager = manager
        self.baseURL = URL(string: "https://api.tvmaze.com")!
        self.favoritesSubject = PassthroughSubject()
    }
    
    func searchMany(query: String) async throws -> [Show] {
        let request = ShowSearchRequestModel(baseURL: baseURL, query: query)
        return try await manager.request(with: request).map { $0.show }
    }
    
    func fetchMany(page: Int?) async throws -> [Show] {
        let request = ShowListRequestModel(baseURL: baseURL, page: page)
        return try await manager.request(with: request)
    }
    
    func isFavorite(_ show: Show) -> Bool {
        favoritesShowsIDs.contains(show.id)
    }
    
    func markAsFavorite(show: Show) {
        var favorites = favoritesShowsIDs
        favorites.append(show.id)
        
        let values = Set(favorites)
        favoritesShowsIDs = Array(values)
        
        favoritesSubject.send()
    }
    
    func removeFromFavorites(show: Show) {
        favoritesShowsIDs.removeAll(where: { $0 == show.id })
        favoritesSubject.send()
    }
    
    func loadFavorites() async throws -> [Show] {
        return try await favoritesShowsIDs
            .map { ShowFetchRequestModel(baseURL: baseURL, showID: $0) }
            .asyncMap {
                try await manager.request(with: $0)
            }
    }
}
