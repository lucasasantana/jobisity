//
//  EncoderError.swift
//  JobsityApplication
//
//  Created by Lucas Antevere Santana on 29/07/22.
//

import Foundation

public enum EncoderError: String, Error {
    case nilParameters  = "The request parameters were empty"
    case encodingFailed = "Parameter encoding failed"
    case missingURL     = "The given URl is nil"
}
