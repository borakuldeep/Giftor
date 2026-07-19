//
//  VideoFrameExtractor.swift
//  Giftor
//
//  Created by Kuldeep Bora on 28.01.26.
//

import AVFoundation
import SwiftUI

struct ExtractedVideo {
    let frames: [CGImage]
    let duration: Double
}

enum VideoFrameExtractor {

    static func extract(
        asset: AVAsset,
        startTime: Double,
        duration: Int,
        quality: GifQuality,
        fps: Int,
        isColor: Bool = true,
        endFrameColor: String = "None"  // ✅ New parameter
    ) async throws -> ExtractedVideo {

        let generator = AVAssetImageGenerator(asset: asset)

        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(
            width: quality.rawValue,
            height: quality.rawValue
        )
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero

        let durationLoaded = try await asset.load(.duration)
        let videoDuration = CMTimeGetSeconds(durationLoaded)

        let maxGIFDuration: Double = Double(duration)
        let clampedStart = max(0, min(startTime, videoDuration))
        let availableDuration = max(0, videoDuration - clampedStart)
        let targetDuration = min(maxGIFDuration, availableDuration)

        guard targetDuration > 0 else {
            throw VideoError.noFrames
        }

        let fpsDouble = Double(fps)
        let frameCount = Int(targetDuration * fpsDouble)

        let ciContext = CIContext()

        var frames: [CGImage] = []

        for i in 0..<frameCount {

            let time = CMTime(
                seconds: clampedStart + (Double(i) / fpsDouble),
                preferredTimescale: durationLoaded.timescale
            )

            let cgImage = try await generateImage(from: generator, at: time)

            if !isColor {
                let ciImage = CIImage(cgImage: cgImage)
                let filter = CIFilter(name: "CIPhotoEffectMono")
                filter?.setValue(ciImage, forKey: kCIInputImageKey)

                if let output = filter?.outputImage,
                    let bwImage = ciContext.createCGImage(
                        output,
                        from: output.extent
                    )
                {
                    frames.append(bwImage)
                }
            } else {
                frames.append(cgImage)
            }
        }

        // ✅ Append end frames if requested
        let colorOption = endFrameColor.lowercased()
        if colorOption == "black" || colorOption == "white",
            let lastFrame = frames.first
        {

            let width = lastFrame.width
            let height = lastFrame.height
            let color: CGColor =
                (colorOption == "black")
                ? CGColor(gray: 0, alpha: 1)
                : CGColor(gray: 1, alpha: 1)

            let extraFrameCount = Int(fpsDouble)

            if let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) {

                context.setFillColor(color)
                context.fill(CGRect(x: 0, y: 0, width: width, height: height))

                if let colorFrame = context.makeImage() {
                    for _ in 0..<extraFrameCount {
                        frames.append(colorFrame)
                    }
                }
            }
        }

        return ExtractedVideo(
            frames: frames,
            duration: targetDuration
        )
    }

    static func generateImage(
        from generator: AVAssetImageGenerator,
        at time: CMTime
    ) async throws -> CGImage {

        try await withCheckedThrowingContinuation { continuation in

            generator.generateCGImageAsynchronously(for: time) {
                cgImage,
                actualTime,
                error in

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let cgImage = cgImage else {
                    continuation.resume(
                        throwing: NSError(domain: "ThumbnailError", code: -1)
                    )
                    return
                }

                continuation.resume(returning: cgImage)
            }
        }
    }

}
