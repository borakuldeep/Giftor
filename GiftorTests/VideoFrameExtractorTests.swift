//
//  VideoFrameExtractorTests.swift
//  GiftorTests
//
//  Created by Kuldeep Bora on 08.08.26.
//

import AVFoundation
import XCTest
@testable import Giftor

final class VideoFrameExtractorTests: XCTestCase {

    var videoURL: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        videoURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        try makeTestVideo(url: videoURL, duration: 2.0)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: videoURL)
        try super.tearDownWithError()
    }

    func testExtractReturnsExpectedFrameCount() async throws {
        let asset = AVURLAsset(url: videoURL)
        let result = try await VideoFrameExtractor.extract(
            asset: asset,
            startTime: 0,
            duration: 2,
            quality: .Low,
            fps: 8
        )
        XCTAssertEqual(result.frames.count, 16) // 2s * 8fps
        XCTAssertEqual(result.duration, 2.0, accuracy: 0.01)
    }

    func testExtractFramesFitQuality() async throws {
        let asset = AVURLAsset(url: videoURL)
        let result = try await VideoFrameExtractor.extract(
            asset: asset,
            startTime: 0,
            duration: 2,
            quality: .Medium,
            fps: 8
        )
        for frame in result.frames {
            XCTAssertLessThanOrEqual(frame.width, GifQuality.Medium.rawValue)
            XCTAssertLessThanOrEqual(frame.height, GifQuality.Medium.rawValue)
        }
    }

    func testExtractStartTimePastEndThrows() async {
        let asset = AVURLAsset(url: videoURL)
        do {
            _ = try await VideoFrameExtractor.extract(
                asset: asset,
                startTime: 10,
                duration: 2,
                quality: .Low,
                fps: 8
            )
            XCTFail("Expected noFrames error when start time is past the video end")
        } catch {
            // Correct: start time past the end yields zero available duration.
        }
    }

    func testExtractTooLongDurationClampsToVideoLength() async throws {
        let asset = AVURLAsset(url: videoURL)
        let result = try await VideoFrameExtractor.extract(
            asset: asset,
            startTime: 0,
            duration: 100,
            quality: .Low,
            fps: 8
        )
        // 2s video, 8fps = 16 frames
        XCTAssertEqual(result.frames.count, 16)
    }

    func testExtractGrayscale() async throws {
        let asset = AVURLAsset(url: videoURL)
        let result = try await VideoFrameExtractor.extract(
            asset: asset,
            startTime: 0,
            duration: 2,
            quality: .Low,
            fps: 8,
            isColor: false
        )
        XCTAssertEqual(result.frames.count, 16)
    }

    func testExtractEndFrameBlack() async throws {
        let asset = AVURLAsset(url: videoURL)
        let result = try await VideoFrameExtractor.extract(
            asset: asset,
            startTime: 0,
            duration: 1,
            quality: .Low,
            fps: 8,
            endFrameColor: "black"
        )
        XCTAssertEqual(result.frames.count, 16) // 8 + 8 end frames
    }
}
