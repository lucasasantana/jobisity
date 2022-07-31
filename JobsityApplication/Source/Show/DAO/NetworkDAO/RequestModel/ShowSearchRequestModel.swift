//
//  ShowSearchRequestModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import Foundation

struct ShowResult: Decodable {
    let score: Double
    let show: Show
}

struct ShowSearchRequestEndpoint: NetworkRouterEndpoint {
    
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let task: HTTPTask
    
    init(baseURL: URL, query: String) {
        self.baseURL = baseURL
        
        self.method = .get
        self.path = "/search/shows"
        self.task = .requestWithParameters(bodyParameters: nil, urlParameters: ["q": query])
    }
}

struct ShowSearchRequestModel: NetworkRequestModel {
    
    typealias ResultModel = [ShowResult]
    typealias EndPoint = ShowSearchRequestEndpoint
    
    let endpoint: ShowSearchRequestEndpoint
    
    init(baseURL: URL, query: String) {
        self.endpoint = ShowSearchRequestEndpoint(baseURL: baseURL, query: query)
    }
}
