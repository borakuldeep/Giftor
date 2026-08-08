//
//  FrameTextRendererTests.swift
//  GiftorTests
//
//  Created by Kuldeep Bora on 08.08.26.
//

import CoreGraphics
import XCTest
@testable import Giftor

final class FrameTextRendererTests: XCTestCase {

    func testDrawTextReturnsSameSizeImage() {
        let image = makeTestImage(width: 200, height: 150)
        let result = FrameTextRenderer.drawText(
            "Hello",
            onto: image,
            waterMark: "GIFTOR"
        )
        XCTAssertEqual(result.width, image.width)
        XCTAssertEqual(result.height, image.height)
    }

    func testDrawTextAllPositions() {
        let image = makeTestImage()
        for position in [TextPosition.top, .middle, .bottom, .bottomLeft] {
            let result = FrameTextRenderer.drawText(
                "Hello",
                onto: image,
                position: position,
                waterMark: ""
            )
            XCTAssertEqual(result.width, image.width)
        }
    }

    func testDrawTextAllSizes() {
        let image = makeTestImage()
        for size in [TextSize.small, .medium, .large] {
            let result = FrameTextRenderer.drawText(
                "Hello",
                onto: image,
                size: size,
                waterMark: ""
            )
            XCTAssertEqual(result.width, image.width)
        }
    }

    func testDrawTextAllColors() {
        let image = makeTestImage()
        for color in TextColorOption.allCases {
            let result = FrameTextRenderer.drawText(
                "Hello",
                onto: image,
                color: color,
                waterMark: ""
            )
            XCTAssertEqual(result.width, image.width)
        }
    }

    func testEmptyTextWithNoWatermarkReturnsSameImage() {
        let image = makeTestImage()
        let result = FrameTextRenderer.drawText(
            "",
            onto: image,
            waterMark: ""
        )
        XCTAssertEqual(result.width, image.width)
        XCTAssertEqual(result.height, image.height)
    }
}
