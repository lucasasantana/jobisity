//
//  HTTPTask.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

/// Defines the HTTP Tasks
public enum HTTPTask {
    
    /// A simple request
    case request
    
    /// A request with parameters on the body and/or the url
    case requestWithParameters(bodyParameters: RequestParameters?, urlParameters: RequestParameters?)
    
    /// A request with parameters on the body and/or the url and/or HTTP Headers
    case requestWithParametersAndHeaders(
        bodyParameters: RequestParameters?,
        urlParameters: RequestParameters?,
        addtionalHeaders: HTTPHeaders?
    )
}
