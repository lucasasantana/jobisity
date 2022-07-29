//
//  URLSessionProvider.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

public protocol URLSessionProvider {
    func dataTask(
        with request: URLRequest,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionProviderDataTask
    
}

public protocol URLSessionProviderDataTask {
    func resume()
    func suspend()
    func cancel()
}

extension URLSessionDataTask: URLSessionProviderDataTask {}

extension URLSession: URLSessionProvider {
    
    public func dataTask(
        with request: URLRequest,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionProviderDataTask {
        self.dataTask(with: request, completionHandler: completion)
    }
}
