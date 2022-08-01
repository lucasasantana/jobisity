//
//  Sequence+async.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 31/07/22.
//

import Combine
import Foundation

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()
        
        for element in self {
            try await values.append(transform(element))
        }
        
        return values
    }
}

extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>,Publishers.SetFailureType<Self, Error>> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}
