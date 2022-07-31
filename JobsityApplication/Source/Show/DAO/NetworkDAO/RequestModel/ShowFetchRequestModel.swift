//
//  ShowFetchRequestModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import Foundation

struct ShowFetchEndpoint: NetworkRouterEndpoint {
    
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let task: HTTPTask
    
    init(baseURL: URL, showID: Int) {
        self.baseURL = baseURL
        
        self.method = .get
        self.path = "/shows/\(showID)"
        self.task = .request
    }
}

struct ShowFetchRequestModel: NetworkRequestModel {
    
    typealias ResultModel = Show
    typealias EndPoint = ShowFetchEndpoint
    
    let endpoint: ShowFetchEndpoint
    
    init(baseURL: URL, showID: Int) {
        self.endpoint = ShowFetchEndpoint(baseURL: baseURL, showID: showID)
    }
}
