//
//  ShowDAO.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

protocol ShowDAO {
    func fetchMany(page: Int?) async throws -> [Show]
}

