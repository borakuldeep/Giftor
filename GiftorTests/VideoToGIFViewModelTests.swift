//
//  VideoToGIFViewModelTests.swift
//  GiftorTests
//
//  Created by Kuldeep Bora on 08.08.26.
//

import XCTest
@testable import Giftor

@MainActor
final class VideoToGIFViewModelTests: XCTestCase {

    var viewModel: VideoToGIFViewModel!

    override func setUp() {
        super.setUp()
        viewModel = VideoToGIFViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - reset()

    func testResetClearsState() throws {
        viewModel.importedPhoto = makeTestImage()
        try viewModel.regenerateGifFromPhoto(settings: makeDefaultSettings())
        viewModel.gifLength = 5
        viewModel.gifQuality = .High
        viewModel.selectedItemType = "video"
        viewModel.errorMessage = "boom"

        viewModel.reset()

        XCTAssertTrue(viewModel.gifFrames.isEmpty)
        XCTAssertNil(viewModel.previewURL)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.gifStartTime, 0.0)
        XCTAssertEqual(viewModel.gifLength, 2)
        XCTAssertEqual(viewModel.gifQuality, .Medium)
        XCTAssertEqual(viewModel.videoLength, 0.0)
        XCTAssertEqual(viewModel.selectedItemType, "")
    }

    // MARK: - updateGifSettings()

    func testUpdateGifSettingsCopiesAllValues() {
        let settings = SettingsDraft(
            gifLength: 3,
            gifFps: 12,
            gifEffect: .fade,
            gifPlaybackSpeed: 2.0,
            gifQuality: .High,
            gifDirection: "rev",
            isGifColored: false,
            waterMark: "TEST",
            endFrame: "black"
        )

        viewModel.updateGifSettings(settings: settings)

        XCTAssertEqual(viewModel.gifPlaybackSpeed, 2.0)
        XCTAssertEqual(viewModel.photoGifEffect, .fade)
        XCTAssertEqual(viewModel.gifQuality, .High)
        XCTAssertEqual(viewModel.gifFps, 12)
        XCTAssertEqual(viewModel.gifDirection, "rev")
        XCTAssertFalse(viewModel.isGifColored)
        XCTAssertEqual(viewModel.waterMark, "TEST")
        XCTAssertEqual(viewModel.gifEndFrameColor, "black")
    }

    // MARK: - savesPhotoAsStill

    func testSavesPhotoAsStillForPhotoWithNoneEffect() {
        viewModel.selectedItemType = "photo"
        viewModel.photoGifEffect = .none
        XCTAssertTrue(viewModel.savesPhotoAsStill)
    }

    func testDoesNotSavePhotoAsStillForAnimatedPhoto() {
        viewModel.selectedItemType = "photo"
        viewModel.photoGifEffect = .zoom
        XCTAssertFalse(viewModel.savesPhotoAsStill)
    }

    func testDoesNotSavePhotoAsStillForVideo() {
        viewModel.selectedItemType = "video"
        viewModel.photoGifEffect = .none
        XCTAssertFalse(viewModel.savesPhotoAsStill)
    }

    // MARK: - regenerateGifFromPhoto

    func testRegenerateFromPhotoWithNoneEffectProducesOneFrame() throws {
        let photo = makeTestImage()
        viewModel.importedPhoto = photo
        let settings = SettingsDraft(
            gifLength: 2,
            gifFps: 8,
            gifEffect: .none,
            gifPlaybackSpeed: 1.0,
            gifQuality: .Medium,
            gifDirection: "fwd",
            isGifColored: true,
            waterMark: "GIFTOR",
            endFrame: "None"
        )

        try viewModel.regenerateGifFromPhoto(settings: settings)

        XCTAssertEqual(viewModel.gifFrames.count, 1)
        XCTAssertNotNil(viewModel.previewURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: viewModel.previewURL!.path))
    }

    func testRegenerateFromPhotoWithZoomEffectProducesMultipleFrames() throws {
        let photo = makeTestImage()
        viewModel.importedPhoto = photo
        let settings = SettingsDraft(
            gifLength: 2,
            gifFps: 8,
            gifEffect: .zoom,
            gifPlaybackSpeed: 1.0,
            gifQuality: .Medium,
            gifDirection: "fwd",
            isGifColored: true,
            waterMark: "GIFTOR",
            endFrame: "None"
        )

        try viewModel.regenerateGifFromPhoto(settings: settings)

        XCTAssertEqual(viewModel.gifFrames.count, 24)
    }

    func testRegenerateFromPhotoWithEndFrame() throws {
        let photo = makeTestImage()
        viewModel.importedPhoto = photo
        let settings = SettingsDraft(
            gifLength: 2,
            gifFps: 8,
            gifEffect: .zoom,
            gifPlaybackSpeed: 1.0,
            gifQuality: .Medium,
            gifDirection: "fwd",
            isGifColored: true,
            waterMark: "GIFTOR",
            endFrame: "white"
        )

        try viewModel.regenerateGifFromPhoto(settings: settings)

        XCTAssertEqual(viewModel.gifFrames.count, 48)
    }

    // MARK: - updateTextOverlay

    func testUpdateTextOverlaySingleDraft() throws {
        viewModel.importedPhoto = makeTestImage()
        try viewModel.regenerateGifFromPhoto(settings: makeDefaultSettings())

        let draft = TextOverlayDraft(
            text: "Hi there",
            textPosition: .top,
            textSize: .medium,
            isBlinking: false,
            textColor: .yellow,
            textTiming: .full
        )

        try viewModel.updateTextOverlay(settings: draft)

        XCTAssertEqual(viewModel.gifText, "Hi there")
        XCTAssertEqual(viewModel.textPosition, .top)
        XCTAssertEqual(viewModel.textSize, .medium)
        XCTAssertNotNil(viewModel.previewURL)
    }

    func testUpdateTextOverlayWithTwoDrafts() throws {
        viewModel.importedPhoto = makeTestImage()
        try viewModel.regenerateGifFromPhoto(settings: makeDefaultSettings())

        let draft1 = TextOverlayDraft(
            text: "First",
            textPosition: .top,
            textSize: .small,
            isBlinking: false,
            textColor: .white,
            textTiming: .full
        )
        let draft2 = TextOverlayDraft(
            text: "Second",
            textPosition: .bottom,
            textSize: .medium,
            isBlinking: true,
            textColor: .red,
            textTiming: .firstHalf
        )

        try viewModel.updateTextOverlay(settings1: draft1, settings2: draft2)

        XCTAssertEqual(viewModel.gifText, "First")
        XCTAssertEqual(viewModel.gifText2, "Second")
        XCTAssertEqual(viewModel.text2Position, .bottom)
        XCTAssertTrue(viewModel.gifText2Blink)
        XCTAssertEqual(viewModel.text2Placement, .firstHalf)
    }

    func testUpdateTextOverlayWithoutSecondDraftLeavesText2() throws {
        viewModel.importedPhoto = makeTestImage()
        try viewModel.regenerateGifFromPhoto(settings: makeDefaultSettings())
        viewModel.gifText2 = "keep me"

        let draft1 = TextOverlayDraft(
            text: "Only",
            textPosition: .top,
            textSize: .small,
            isBlinking: false,
            textColor: .white,
            textTiming: .full
        )

        try viewModel.updateTextOverlay(settings1: draft1, settings2: nil)

        XCTAssertEqual(viewModel.gifText2, "keep me")
    }

    // MARK: - generatePreviewURL

    func testGeneratePreviewURLProducesGifFile() throws {
        viewModel.importedPhoto = makeTestImage()
        try viewModel.regenerateGifFromPhoto(settings: makeDefaultSettings())

        XCTAssertNotNil(viewModel.previewURL)
        XCTAssertEqual(viewModel.previewURL?.pathExtension, "gif")
        XCTAssertNotNil(viewModel.extractedVideo)
        XCTAssertEqual(viewModel.extractedVideo?.frames.count, viewModel.gifFrames.count)
    }

    // MARK: - Helpers

    private func makeDefaultSettings() -> SettingsDraft {
        SettingsDraft(
            gifLength: 2,
            gifFps: 8,
            gifEffect: .zoom,
            gifPlaybackSpeed: 1.0,
            gifQuality: .Medium,
            gifDirection: "fwd",
            isGifColored: true,
            waterMark: "GIFTOR",
            endFrame: "None"
        )
    }
}
