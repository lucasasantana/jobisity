//
//  File.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

public typealias NetworkCachePolice = URLRequest.CachePolicy

public class Router<EndPoint: NetworkRouterEndpoint>: NetworkRouter {
    
    private var task: URLSessionProviderDataTask?
    
    private var session: URLSessionProvider
    
    init(urlSession: URLSessionProvider = URLSession.shared) {
        self.session = urlSession
    }
    
    public func request(route: EndPoint, cachePolicy: NetworkCachePolice, timeout: TimeInterval, completion: @escaping NetworkRouterCompletion) {
        
        do {
            
            let request = try self.buildRequest(from: route, cachePolicy: cachePolicy, timeout: timeout)
            
            task = session.dataTask(with: request) { [weak self ] (data, response, error) in
                
                if let safeError = error {
                    completion(.failure(.taskError(safeError)))
                    
                } else if let response = response {
                    completion(.success(result: data, response: response))
                    
                } else {
                    completion(.failure(.nullResponse))
                }
                
                self?.task = nil
            }
            
            task?.resume()
            
        } catch let encoderError as EncoderError {
            completion(.failure(.requestBuildingFailed(encoderError)))
            
        } catch {
            completion(.failure(.taskError(error)))
        }
    }
    
    public func suspend() {
        task?.suspend()
    }
    
    public func resume() {
        task?.resume()
    }
    
    public func cancel() {
       task?.cancel()
    }
    
    private func buildRequest(from route: NetworkRouterEndpoint, cachePolicy: NetworkCachePolice, timeout: TimeInterval) throws -> URLRequest {
        
        let url = route.baseURL.appendingPathComponent(route.path)
        
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        
        request.httpMethod = route.method.rawValue
        
        switch route.task {
            
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
            case .requestWithParameters(let bodyParameters,let urlParameters):
                try self.configureParameters(bodyParameters: bodyParameters, urlParameters: urlParameters, request: &request)
                
            case .requestWithParametersAndHeaders(let bodyParameters, let urlParameters, let addtionalHeaders):
                
                try self.configureParameters(bodyParameters: bodyParameters, urlParameters: urlParameters, request: &request)
                self.add(additionalHeaders: addtionalHeaders, request: &request)
        }
        
        return request
    }
    
    private func configureParameters(bodyParameters: RequestParameters?, urlParameters: RequestParameters?, request: inout URLRequest) throws {
        if let bodyParameters = bodyParameters {
            try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
        }
        
        if let urlParameters = urlParameters {
            try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
        }
    }
    
    private func add(additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (header, value) in headers {
            request.setValue(value, forHTTPHeaderField: header)
        }
    }
}
