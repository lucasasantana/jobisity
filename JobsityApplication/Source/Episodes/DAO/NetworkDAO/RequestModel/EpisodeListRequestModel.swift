//
//  EpisodeListRequestModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 30/07/22.
//

import Foundation

struct EpisodeListEndpoint: NetworkRouterEndpoint {
    
    let baseURL: URL
    let path: String
    
    let method: HTTPMethod
    let task: HTTPTask
    
    init(baseURL: URL, showID: Int) {
        self.baseURL = baseURL
        self.path = "/shows/\(showID)/episodes"
        self.method = .get
        self.task = .request
    }
    
}

struct EpisodeListRequestModel: NetworkRequestModel {
    
    typealias ResultModel = [Episode]
    typealias EndPoint = EpisodeListEndpoint
    
    let endpoint: EpisodeListEndpoint
    
    init(baseURL: URL, showID: Int) {
        self.endpoint = EpisodeListEndpoint(baseURL: baseURL, showID: showID)
    }
}
