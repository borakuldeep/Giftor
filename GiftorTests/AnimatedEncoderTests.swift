//
//  AnimatedEncoderTests.swift
//  GiftorTests
//
//  Created by Kuldeep Bora on 08.08.26.
//

import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import Giftor

final class AnimatedEncoderTests: XCTestCase {

    func testEncodeGIFProducesGifFile() throws {
        let frames = generateGifFrames(from: makeTestImage(), effect: .zoom, frameCount: 12)
        let url = try AnimatedEncoder.encodeGIF(frames: frames, duration: 2.0)

        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertEqual(url.pathExtension, "gif")
    }

    func testEncodeGIFContainsAllFrames() throws {
        let frames = generateGifFrames(from: makeTestImage(), effect: .zoom, frameCount: 10)
        let url = try AnimatedEncoder.encodeGIF(frames: frames, duration: 2.0)
        defer { try? FileManager.default.removeItem(at: url) }

        let source = CGImageSourceCreateWithURL(url as CFURL, nil)!
        XCTAssertEqual(CGImageSourceGetCount(source), 10)
        XCTAssertEqual(
            CGImageSourceGetType(source) as String?,
            UTType.gif.identifier
        )
    }

    func testEncodeGIFEmptyFramesThrows() {
        XCTAssertThrowsError(try AnimatedEncoder.encodeGIF(frames: [], duration: 2.0))
    }
}
