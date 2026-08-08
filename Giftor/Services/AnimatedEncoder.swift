//
//  AnimatedEncoder.swift
//  Giftor
//
//  Created by Kuldeep Bora on 28.01.26.
//


import ImageIO
import UniformTypeIdentifiers
import Photos

enum AnimatedEncoder {

    static func encodeGIF(
        frames: [CGImage],
        duration: Double,
        speed: Double = 1.0
    ) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("gif")

        let baseFrameDelay = duration / Double(frames.count)
        let frameDelay = baseFrameDelay / speed

        guard let dest = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.gif.identifier as CFString,
            frames.count,
            nil
        ) else {
            throw EncodeError.creationFailed
        }

        let props: [CFString: Any] = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 0
            ]
        ]

        CGImageDestinationSetProperties(dest, props as CFDictionary)

        frames.forEach {
            CGImageDestinationAddImage(
                dest,
                $0,
                [
                    kCGImagePropertyGIFDictionary: [
                        kCGImagePropertyGIFDelayTime: frameDelay
                    ]
                ] as CFDictionary
            )
        }

        guard CGImageDestinationFinalize(dest) else {
            throw EncodeError.finalizeFailed
        }

        return url
    }

    static func saveGIFToPhotos(_ url: URL) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest
                .forAsset()
                .addResource(with: .photo, fileURL: url, options: nil)
        }
    }

    static func savePhotoToPhotos(_ image: CGImage) async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")

        guard let dest = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            throw EncodeError.creationFailed
        }

        CGImageDestinationAddImage(dest, image, nil)

        guard CGImageDestinationFinalize(dest) else {
            throw EncodeError.finalizeFailed
        }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest
                .forAsset()
                .addResource(with: .photo, fileURL: url, options: nil)
        }
    }
}
