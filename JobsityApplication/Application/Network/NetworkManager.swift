//
//  NetworkManager.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

public protocol NetworkRequestModel {
    associatedtype ResultModel: Decodable
    associatedtype EndPoint: NetworkRouterEndpoint
    
    var endpoint: EndPoint { get }
}

public class NetworkManager {
    
    public enum NetworkError: Error {
        
        case invalidParameters(EncoderError)
        
        case authenticationError
        case badRequest
        case outdated
        
        case failed
        case urlTaskFailed(Error)
       
        case serverError
        case notFound
        case forbidden
        
        case nullResponse
        case nonHTTPURLResponse
        
        case noData
        case unableToDecode(Error)
        
        case deallocatedNetworkManagerObject
    }
    
    public enum ResponseResult {
        case success
        case failure(NetworkError)
    }
    
    private var urlSession: URLSessionProvider
    
    public init(urlSession: URLSessionProvider = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    public func request<Request: NetworkRequestModel>(
        with model: Request,
        cahcePolicy: NetworkCachePolice = .useProtocolCachePolicy,
        timeout: TimeInterval = 2
    ) async throws -> Request.ResultModel {
        return try await withCheckedThrowingContinuation({ continuation in
            request(with: model, cahcePolicy: cahcePolicy, timeout: timeout) { result in
                continuation.resume(with: result)
            }
        })
    }
    
    public func request<Request: NetworkRequestModel>(
        with model: Request,
        cahcePolicy: NetworkCachePolice = .useProtocolCachePolicy,
        timeout: TimeInterval = 2,
        completion: @escaping (Result<Request.ResultModel, NetworkError>) -> Void
    ) {
    
        Router<Request.EndPoint>().request(route: model.endpoint, cachePolicy: cahcePolicy, timeout: timeout) { [weak self] (result) in
            
            guard let self = self else {
                completion(.failure(.deallocatedNetworkManagerObject))
                return
            }
            
            switch result {
                
                case .success(let data, let response):
                    
                    guard let response = response as? HTTPURLResponse else {
                        completion(.failure(.nonHTTPURLResponse))
                        return
                    }
                    
                    let responseResult = self.handle(networkResponse: response)
                    
                    switch responseResult {
                        
                        case .success:
                            
                            guard let responseData = data else {
                                completion(.failure(.noData))
                                return
                            }
                            
                            do {
                                
                                let decodedData = try JSONDecoder().decode(Request.ResultModel.self, from: responseData)
                            
                                completion(.success(decodedData))
                                
                            } catch {
                                completion(.failure(.unableToDecode(error)))
                            }
                    
                        case .failure(let error):
                            completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(self.handle(routerError: error)))
            }
        }
    }
    
    private func handle(networkResponse response: HTTPURLResponse) -> ResponseResult {
        
        switch response.statusCode {
            
            case 200...299: return .success
            case 400:       return .failure(.badRequest)
            case 401:       return .failure(.authenticationError)
            case 403:       return .failure(.forbidden)
            case 500...599: return .failure(.serverError)
            case 600:       return .failure(.outdated)
            default:        return .failure(.failed)
        }
    }
    
    private func handle(routerError: NetworkRouterError) -> NetworkError {
        
        switch routerError {
            
            case .nullResponse:
                return .nullResponse
            
            case .requestBuildingFailed(let encoderError):
                return .invalidParameters(encoderError)
                
            case .taskError(let error):
                return .urlTaskFailed(error)
        }
    }
}
