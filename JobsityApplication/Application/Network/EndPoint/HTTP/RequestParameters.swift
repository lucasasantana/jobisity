//
//  RequestParameters.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

public typealias RequestParameters = [String: Any]

public protocol RequestParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: RequestParameters) throws
}
