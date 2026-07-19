//
//  VideoError.swift
//  Giftor
//
//  Created by Kuldeep Bora on 28.01.26.
//
import SwiftUI

enum VideoError: LocalizedError {
    case noFrames
    case videoTooLong
    case exportFailed
    
    var errorDescription: String? {
        switch self {
        case .noFrames:
            return "Unable to extract frames from the video."
        case .videoTooLong:
            return "Please select a video shorter than 45 seconds."
        case .exportFailed:
            return "Export to lower quality failed"
        }
    }

}

enum EncodeError: LocalizedError {
    case creationFailed
    case finalizeFailed

    var errorDescription: String? {
        "Failed to encode animation."
    }
}


enum ImageImportError: LocalizedError {
    case gifNotSupported
    case invalidData

    var errorDescription: String? {
        switch self {
        case .gifNotSupported:
            return "GIF images are not supported."
        case .invalidData:
            return "Invalid Data"
        }
    }
}
