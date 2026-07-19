//
//  VideoImportError.swift
//  Giftor
//
//  Created by Kuldeep Bora on 31.01.26.
//


import PhotosUI
import SwiftUI

enum VideoImportError: Error {
    case invalidData
}

struct ImportService {

    static func loadVideo(from item: PhotosPickerItem) async throws -> URL {

        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw VideoImportError.invalidData
        }

        let tempURL = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")

        try data.write(to: tempURL, options: .atomic)

        return tempURL
    }
    
    static func loadCGImage(from item: PhotosPickerItem) async throws -> CGImage {
        
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw NSError(domain: "ImageLoad", code: 0)
        }

        let options: CFDictionary = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceCreateThumbnailWithTransform: true // correct orientation
        ] as CFDictionary

        guard
            let source = CGImageSourceCreateWithData(data as CFData, options),
            let image = CGImageSourceCreateImageAtIndex(source, 0, options)
        else {
            throw NSError(domain: "ImageDecode", code: 0)
        }

        return image
    }
}
