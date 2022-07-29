//
//  NetworkRouterError.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

/// Describes errors related to an Network Error
public enum NetworkRouterError: Error {
   
    /// Represents that the callback returned but there was no valid response
    case nullResponse
    
    /// Represents that the URLRequest could not be manufactured
    case requestBuildingFailed(EncoderError)
    
    /// An error ocurred during the data task on URL Session
    case taskError(Error)
}
