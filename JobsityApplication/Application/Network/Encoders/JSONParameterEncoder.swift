//
//  JSONParameterEncoder.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation
import os

public struct JSONParameterEncoder: RequestParameterEncoder {
    public static func encode(urlRequest request: inout URLRequest, with parameters: RequestParameters) throws {
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            request.httpBody = jsonAsData
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
        } catch {
            print("Error when encoding JSON Paramenters: \(error.localizedDescription)")
            throw EncoderError.encodingFailed
        }
    }
}
