//
//  ShowDAO.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

protocol ShowDAO {
    func isFavorite(_ show: Show) -> Bool
    func markAsFavorite(show: Show)
    func removeFromFavorites(show: Show)
    func loadFavorites() async throws -> [Show]
    func searchMany(query: String) async throws -> [Show]
    func fetchMany(page: Int?) async throws -> [Show]
}

