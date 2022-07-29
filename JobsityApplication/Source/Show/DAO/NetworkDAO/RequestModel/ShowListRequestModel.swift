//
//  ShowListRequestModel.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

struct ShowListRequestEndpoint: NetworkRouterEndpoint {
    
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let task: HTTPTask
    
    init(baseURL: URL, page: Int?) {
        self.baseURL = baseURL
        
        self.method = .get
        self.path = "/shows"
        
        if let page = page {
            self.task = .requestWithParameters(bodyParameters: nil, urlParameters: ["page": page])
        } else {
            self.task = .request
        }
    }
}

struct ShowListRequestModel: NetworkRequestModel {

    typealias ResultModel = [Show]
    typealias EndPoint = ShowListRequestEndpoint
    
    let endpoint: ShowListRequestEndpoint
    
    init(baseURL: URL, page: Int?) {
        self.endpoint = ShowListRequestEndpoint(baseURL: baseURL, page: page)
    }
}
