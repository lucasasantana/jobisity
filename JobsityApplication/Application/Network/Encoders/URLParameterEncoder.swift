//
//  URLParameterEncoder.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

public struct URLParameterEncoder: RequestParameterEncoder {
    
    public static func encode(urlRequest request: inout URLRequest, with parameters: RequestParameters) throws {
        guard let url = request.url else { throw EncoderError.missingURL }
        
        if var components = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
            components.queryItems = parameters.map { (key, value) -> URLQueryItem in
                let value = "\(value)"
                return URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
            }
            
            request.url = components.url
        }
        
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
}
