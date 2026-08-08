//
//  VideoToGIFViewModel.swift
//  Giftor
//
//  Created by Kuldeep Bora on 28.01.26.
//
import PhotosUI
import SwiftUI

enum GifQuality: Int {
    case Low = 320
    case Medium = 480
    case High = 720
}

enum TextPosition {
    case top
    case middle
    case bottom
    case bottomLeft
}

enum TextSize {
    case small  // current size
    case medium
    case large  // double size + bold
}

enum TextTiming {
    case firstHalf
    case secondHalf
    case full
}

@MainActor
@Observable
final class VideoToGIFViewModel {
    var gifStartTime = 0.0
    var gifLength: Int = 2
    var gifQuality = GifQuality.Low
    var videoLength = 0.0
    var gifFps = 8
    var gifDirection = "fwd"
    var gifTextBlink = false
    var gifTextColor = TextColorOption.white

    var isProcessing = false
    var errorMessage: String?
    var previewURL: URL?
    var asset: AVURLAsset?
    var showSavedToast = false
    var showErrorToast = false
    var selectedItemType = ""

    var importedPhoto: CGImage?
    var photoGifEffect = GifEffect.zoom
    var gifPlaybackSpeed = 1.0
    var isGifColored: Bool = true
    var gifEndFrameColor: String = "None" // None, black, white

    var gifText = "Your text"
    var textPosition: TextPosition = .top
    var textSize: TextSize = .medium
    var textPlacement = TextTiming.full
    
    // Text 2 related properties
    var gifText2Blink = false
    var gifText2Color = TextColorOption.white
    var text2Position: TextPosition = .bottom   // default position for text2
    var text2Size: TextSize = .medium
    var text2Placement: TextTiming = .full
    var gifText2 = ""
    
    
    var waterMark = "GIFTOR"

    private(set) var gifFrames: [CGImage] = []
    private(set) var extractedVideo: ExtractedVideo?

    func checkVideoLength(url: URL, asset: AVURLAsset) async throws -> Bool {
        let duration = try await asset.load(.duration)
        let videoDuration = CMTimeGetSeconds(duration)

        let maxAllowedDuration: Double = 45.0

        if videoDuration <= maxAllowedDuration {
            videoLength = videoDuration
            return true
        }
        return false
    }

    func saveCompressedVideo(asset: AVAsset) async throws {
        let tempDir = FileManager.default.temporaryDirectory
        let outputURL = tempDir.appendingPathComponent(
            "tempClipGiftor.mp4"
        )

        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        try await exportCompressedVideo(asset: asset, outputURL: outputURL)
    }

    func generatePreviewURL() throws {

        var renderedFrames: [CGImage] = []
        let totalFrames = gifFrames.count
        let halfIndex = totalFrames / 2

        // Helper closures for timing/blink logic per text
        func shouldShow(index: Int, placement: TextTiming) -> Bool {
            switch placement {
            case .full:
                return true
            case .firstHalf:
                return index < halfIndex
            case .secondHalf:
                return index >= halfIndex
            }
        }

        // Blink logic: visible during the second half of each second
        func isBlinkOn(index: Int) -> Bool {
            let frameDuration = 1.0 / Double(gifFps)
            let currentTime = Double(index) * frameDuration
            let timeInSecond = currentTime.truncatingRemainder(dividingBy: 1.0)
            return timeInSecond >= 0.5
        }

        renderedFrames = gifFrames.enumerated().map { index, baseFrame in
            // First layer: text1 (no watermark to avoid double drawing)
            let showText1ByPlacement = shouldShow(index: index, placement: textPlacement)
            let showText1ByBlink = gifTextBlink ? isBlinkOn(index: index) : true
            let text1ToDraw = (showText1ByPlacement && showText1ByBlink) ? gifText : ""

            let withText1 = FrameTextRenderer.drawText(
                text1ToDraw,
                onto: baseFrame,
                position: textPosition,
                size: textSize,
                color: gifTextColor,
                waterMark: waterMark // single watermark draw on first text
            )

            // Second layer: text2 (also apply its own placement/blink); draw watermark here
            
            if gifText2 != "" {
                let showText2ByPlacement = shouldShow(index: index, placement: text2Placement)
                let showText2ByBlink = gifText2Blink ? isBlinkOn(index: index) : true
                let text2ToDraw = (showText2ByPlacement && showText2ByBlink) ? gifText2 : ""
                
                let withText2 = FrameTextRenderer.drawText(
                    text2ToDraw,
                    onto: withText1,
                    position: text2Position,
                    size: text2Size,
                    color: gifText2Color,
                    waterMark: "" // avoid drawing watermark on second text
                )
                
                return withText2
            }
            else {
                return withText1
            }
        }

        let updatedResult = ExtractedVideo(
            frames: renderedFrames,
            duration: Double(gifLength)
        )

        extractedVideo = updatedResult

        previewURL = try AnimatedEncoder.encodeGIF(
            frames: renderedFrames,
            duration: Double(gifLength),
            speed: gifPlaybackSpeed
        )
    }

    func updateGifSettings(settings: SettingsDraft) {
        gifPlaybackSpeed = settings.gifPlaybackSpeed
        photoGifEffect = settings.gifEffect
        gifQuality = settings.gifQuality
        gifFps = settings.gifFps
        gifDirection = settings.gifDirection
        isGifColored = settings.isGifColored
        waterMark = settings.waterMark
        gifEndFrameColor = settings.endFrame
    }

    func updateTextOverlay(settings: TextOverlayDraft) throws {
        isProcessing = true
        gifText = settings.text
        textPosition = settings.textPosition
        textSize = settings.textSize
        gifTextBlink = settings.isBlinking
        gifTextColor = settings.textColor
        textPlacement = settings.textTiming
        try generatePreviewURL()
        isProcessing = false
    }

    // New overload to accept two drafts (Text 1 and optional Text 2)
    func updateTextOverlay(settings1: TextOverlayDraft, settings2: TextOverlayDraft?) throws {
        isProcessing = true

        // Text 1
        gifText = settings1.text
        textPosition = settings1.textPosition
        textSize = settings1.textSize
        gifTextBlink = settings1.isBlinking
        gifTextColor = settings1.textColor
        textPlacement = settings1.textTiming

        // Text 2 (if provided)
        if let s2 = settings2 {
            gifText2 = s2.text
            text2Position = s2.textPosition
            text2Size = s2.textSize
            gifText2Blink = s2.isBlinking
            gifText2Color = s2.textColor
            text2Placement = s2.textTiming
        }

        try generatePreviewURL()
        isProcessing = false
    }

    func generateGif(asset: AVURLAsset, settings: SettingsDraft? = nil)
        async throws
    {
        if settings != nil {
            updateGifSettings(settings: settings!)
        }
        let result = try await VideoFrameExtractor.extract(
            asset: asset,
            startTime: gifStartTime,
            duration: gifLength,
            quality: gifQuality,
            fps: gifFps,
            isColor: isGifColored,
            endFrameColor: gifEndFrameColor
        )

        gifFrames = result.frames  // save frames in model
        if gifDirection == "rev" {
            gifFrames = result.frames.reversed()
        } else {
            gifFrames = result.frames
        }
        gifLength = Int(result.duration)

        try generatePreviewURL()
    }

    func regenerateGifFromPhoto(settings: SettingsDraft) throws {
        isProcessing = true
        updateGifSettings(settings: settings)
        gifFrames = generateGifFrames(
            from: importedPhoto!,
            effect: settings.gifEffect,
            maxDimension: CGFloat(gifQuality.rawValue),
            isColor: isGifColored,
            endFrameColor: gifEndFrameColor
        )
        try generatePreviewURL()
        isProcessing = false
    }

    func processImportedPhoto(item: PhotosPickerItem) async throws {

        reset()
        selectedItemType = "photo"
        isProcessing = true
        do {
            if item.supportedContentTypes.contains(.gif) {
                throw ImageImportError.gifNotSupported
            }
            let photo = try await ImportService.loadCGImage(from: item)
            gifFrames = generateGifFrames(from: photo, effect: .zoom, isColor: isGifColored)
            try generatePreviewURL()
            importedPhoto = photo
        } catch {
            isProcessing = false
            errorMessage = error.localizedDescription
            showErrorToast = true
        }
        isProcessing = false

    }

    func loadVideo(from source: VideoSource) async {
        reset()
        selectedItemType = "video"
        isProcessing = true

        do {
            let localURL = try await resolveVideoURL(from: source)
            asset = AVURLAsset(url: localURL)
            let isVideoTooLong = try await checkVideoLength(url: localURL, asset: asset!)
            
            guard isVideoTooLong == true else {
                throw VideoError.videoTooLong
            }

            try await generateGif(asset: asset!)

        } catch {
            errorMessage = error.localizedDescription
            showErrorToast = true
        }

        isProcessing = false
        Task {
            try await saveCompressedVideo(asset: asset!)
            let smallFileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(
                    "tempClipGiftor.mp4"
                )
            guard FileManager.default.fileExists(atPath: smallFileURL.path)
            else {
                throw VideoError.exportFailed
            }
            asset = AVURLAsset(url: smallFileURL)
        }
    }

    // 🆕 Convert source → local file URL

    private func resolveVideoURL(from source: VideoSource) async throws -> URL {
        switch source {

        case .photos(let item):

            let url = try await ImportService.loadVideo(
                from: item
            )

            return url

        case .file(let url):
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                return url
            } else {
                throw VideoError.noFrames
            }
        }
    }

    func export() async {
        isProcessing = true
        errorMessage = nil

        do {
            if selectedItemType == "photo", photoGifEffect == .none,
               let frame = extractedVideo?.frames.first {
                try await AnimatedEncoder.savePhotoToPhotos(frame)
            } else {
                guard extractedVideo != nil else { return }
                try await AnimatedEncoder.saveGIFToPhotos(previewURL!)
            }
            showSavedToast = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isProcessing = false
    }

    func reset() {
        gifFrames.removeAll()
        previewURL = nil
        errorMessage = nil
        gifStartTime = 0.0
        gifLength = 2
        gifQuality = GifQuality.Medium
        videoLength = 0.0
        selectedItemType = ""
    }
}
