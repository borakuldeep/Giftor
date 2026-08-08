//
//  ImageToGIFGeneratorTests.swift
//  GiftorTests
//
//  Created by Kuldeep Bora on 08.08.26.
//

import CoreGraphics
import XCTest
@testable import Giftor

final class ImageToGIFGeneratorTests: XCTestCase {

    // MARK: - GifEffect enum

    func testGifEffectAllCasesOrder() {
        XCTAssertEqual(
            GifEffect.allCases.map(\.rawValue),
            ["none", "zoom", "fade", "slideLeft", "pulse", "wobble", "bounce"]
        )
        XCTAssertEqual(GifEffect.none.id, "none")
    }

    // MARK: - generateGifFrames

    func testNoneEffectReturnsSingleFrame() {
        let frames = generateGifFrames(from: makeTestImage(), effect: .none)
        XCTAssertEqual(frames.count, 1)
    }

    func testNoneEffectFrameIsDownscaled() {
        let frames = generateGifFrames(
            from: makeTestImage(width: 1000, height: 800),
            effect: .none,
            maxDimension: 480
        )
        XCTAssertEqual(frames.count, 1)
        XCTAssertLessThanOrEqual(frames[0].width, 480)
        XCTAssertLessThanOrEqual(frames[0].height, 480)
    }

    func testAnimatedEffectsReturnRequestedFrameCount() {
        for effect in [GifEffect.zoom, .fade, .slideLeft, .pulse, .wobble, .bounce] {
            let frames = generateGifFrames(
                from: makeTestImage(),
                effect: effect,
                frameCount: 24
            )
            XCTAssertEqual(frames.count, 24, "Expected 24 frames for \(effect.rawValue)")
        }
    }

    func testCustomFrameCount() {
        let frames = generateGifFrames(
            from: makeTestImage(),
            effect: .zoom,
            frameCount: 10
        )
        XCTAssertEqual(frames.count, 10)
    }

    func testEndFrameBlackAppendsFrames() {
        let frames = generateGifFrames(
            from: makeTestImage(),
            effect: .zoom,
            frameCount: 24,
            endFrameColor: "black"
        )
        XCTAssertEqual(frames.count, 48)
    }

    func testEndFrameWhiteAppendsFrames() {
        let frames = generateGifFrames(
            from: makeTestImage(),
            effect: .zoom,
            frameCount: 24,
            endFrameColor: "white"
        )
        XCTAssertEqual(frames.count, 48)
    }

    func testEndFrameNoneDoesNotAppend() {
        let frames = generateGifFrames(
            from: makeTestImage(),
            effect: .zoom,
            frameCount: 24,
            endFrameColor: "None"
        )
        XCTAssertEqual(frames.count, 24)
    }

    func testGrayscaleStillHonorsEffect() {
        let frames = generateGifFrames(
            from: makeTestImage(),
            effect: .none,
            isColor: false
        )
        XCTAssertEqual(frames.count, 1)
    }

    // MARK: - downscaleCGImage

    func testDownscaleLeavesSmallImageUnchanged() {
        let image = makeTestImage(width: 100, height: 50)
        let result = downscaleCGImage(image, maxDimension: 480)
        XCTAssertEqual(result.width, 100)
        XCTAssertEqual(result.height, 50)
    }

    func testDownscaleScalesLargeImage() {
        let image = makeTestImage(width: 1600, height: 800)
        let result = downscaleCGImage(image, maxDimension: 480)
        XCTAssertLessThanOrEqual(result.width, 480)
        XCTAssertLessThanOrEqual(result.height, 480)
        // Aspect ratio preserved
        XCTAssertEqual(Double(result.width) / Double(result.height), 2.0, accuracy: 0.01)
    }

    // MARK: - renderFrame

    func testRenderFrameNoneDrawsImage() {
        let image = makeTestImage()
        let frame = renderFrame(
            image: image,
            size: CGSize(width: image.width, height: image.height),
            effect: .none,
            progress: 0
        )
        XCTAssertNotNil(frame)
        XCTAssertEqual(frame?.width, image.width)
    }

    func testRenderFrameGrayscale() {
        let image = makeTestImage()
        let frame = renderFrame(
            image: image,
            size: CGSize(width: image.width, height: image.height),
            effect: .none,
            progress: 0,
            isColor: false
        )
        XCTAssertNotNil(frame)
    }
}
