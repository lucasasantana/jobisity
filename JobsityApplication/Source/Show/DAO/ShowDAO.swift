//
//  ShowDAO.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

protocol ShowDAO {
    func searchMany(query: String) async throws -> [Show]
    func fetchMany(page: Int?) async throws -> [Show]
}

