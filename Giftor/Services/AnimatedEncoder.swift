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

        let url = tempURL(ext: "gif")

        // Base frame delay
        let baseFrameDelay = duration / Double(frames.count)

        // Adjust for playback speed
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

    static func encodeGIFOld(
        frames: [CGImage],
        duration: Double,
    ) throws -> URL {

        let url = tempURL(ext: "gif")
        let frameDelay = duration / Double(frames.count)

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

    static func encodeHEIC(
        frames: [CGImage],
        duration: Double
    ) throws -> URL {

        let url = tempURL(ext: "heic")
        let frameDelay = duration / Double(frames.count)

        guard let dest = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.heic.identifier as CFString,
            frames.count,
            nil
        ) else {
            throw EncodeError.creationFailed
        }

        frames.forEach {
            CGImageDestinationAddImage(
                dest,
                $0,
                [
                    kCGImagePropertyHEICSDictionary: [
                        kCGImagePropertyHEICSDelayTime: frameDelay
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


    static func saveHEICToPhotos(_ url: URL) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest
                .forAsset()
                .addResource(with: .photo, fileURL: url, options: nil)
        }
    }

    private static func tempURL(ext: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(ext)
    }
}
