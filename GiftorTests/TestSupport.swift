//
//  TestSupport.swift
//  GiftorTests
//
//  Created by Kuldeep Bora on 08.08.26.
//

import AVFoundation
import CoreGraphics
import XCTest

/// Creates a solid-color RGBA image for testing frame generation.
func makeTestImage(width: Int = 200, height: Int = 150) -> CGImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    context.setFillColor(CGColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0))
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    return context.makeImage()!
}

/// Generates a short solid-color video clip for testing frame extraction.
func makeTestVideo(
    url: URL,
    duration: Double = 2.0,
    width: Int = 120,
    height: Int = 90
) throws {
    let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
    let settings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: width,
        AVVideoHeightKey: height,
    ]
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
        assetWriterInput: input,
        sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height,
        ]
    )
    writer.add(input)
    writer.startWriting()
    writer.startSession(atSourceTime: .zero)

    let fps = 30
    let frameCount = Int(duration * Double(fps))
    for index in 0..<frameCount {
        while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.001) }

        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(nil, adaptor.pixelBufferPool!, &pixelBuffer)
        guard let buffer = pixelBuffer else { continue }

        CVPixelBufferLockBaseAddress(buffer, [])
        let base = CVPixelBufferGetBaseAddress(buffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let bps = 4
        let red = UInt8(50 + index % 100)
        for row in 0..<height {
            let rowBase = base!.advanced(by: row * bytesPerRow)
            for col in 0..<width {
                let pixel = rowBase.advanced(by: col * bps)
                pixel.storeBytes(of: red, as: UInt8.self)
                pixel.advanced(by: 1).storeBytes(of: 120, as: UInt8.self)
                pixel.advanced(by: 2).storeBytes(of: 60, as: UInt8.self)
                pixel.advanced(by: 3).storeBytes(of: 255, as: UInt8.self)
            }
        }
        CVPixelBufferUnlockBaseAddress(buffer, [])

        adaptor.append(
            buffer,
            withPresentationTime: CMTime(value: CMTimeValue(index), timescale: CMTimeScale(fps))
        )
    }

    input.markAsFinished()
    let semaphore = DispatchSemaphore(value: 0)
    writer.finishWriting { semaphore.signal() }
    semaphore.wait()

    if writer.status != .completed {
        throw writer.error ?? VideoFileExportError.exportFailed
    }
}

enum VideoFileExportError: Error {
    case exportFailed
}
