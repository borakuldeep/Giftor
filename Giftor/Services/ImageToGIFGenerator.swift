
import UIKit

enum GifEffect: String, CaseIterable, Identifiable {
    case none
    case zoom
    case fade
    case slideLeft
    case pulse
    case wobble
    case bounce
    
    var id: String { self.rawValue }
}

func generateGifFrames(
    from image: CGImage,
    effect: GifEffect,
    frameCount: Int = 24,
    maxDimension: CGFloat = 480,
    isColor: Bool = true,
    endFrameColor: String = "None"   // ✅ New parameter
) -> [CGImage] {

    let baseImage = downscaleCGImage(image, maxDimension: maxDimension)
    
    if effect == .none {
            if isColor {
                return [baseImage]
            } else {
                return [renderFrame(
                    image: baseImage,
                    size: CGSize(width: baseImage.width, height: baseImage.height),
                    effect: .none,
                    progress: 0,
                    isColor: false
                )].compactMap { $0 }
            }
        }

    let size = CGSize(
        width: baseImage.width,
        height: baseImage.height
    )

    var frames: [CGImage] = (0..<frameCount).compactMap { i in
        let progress = CGFloat(i) / CGFloat(frameCount - 1)
        return renderFrame(
            image: baseImage,
            size: size,
            effect: effect,
            progress: progress,
            isColor: isColor
        )
    }

    // ✅ Append end frames if requested
    let colorOption = endFrameColor.lowercased()
    if colorOption == "black" || colorOption == "white",
       let firstFrame = frames.first {

        let width = firstFrame.width
        let height = firstFrame.height

        let color: CGColor = (colorOption == "black")
            ? CGColor(gray: 0, alpha: 1)
            : CGColor(gray: 1, alpha: 1)

        let extraFrameCount = frameCount // ≈ 1s

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

    return frames
}

func renderFrame(
    image: CGImage,
    size: CGSize,
    effect: GifEffect,
    progress: CGFloat,
    isColor: Bool = true   // ✅ New parameter
) -> CGImage? {

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

    guard let context = CGContext(
        data: nil,
        width: Int(size.width),
        height: Int(size.height),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: bitmapInfo
    ) else { return nil }

    context.clear(CGRect(origin: .zero, size: size))
    context.saveGState()

    applyEffect(
        effect,
        progress: progress,
        image: image,
        size: size,
        context: context
    )

    context.restoreGState()

    guard let outputImage = context.makeImage() else { return nil }

    // ✅ Convert to black & white if needed
    if !isColor {
        let ciImage = CIImage(cgImage: outputImage)
        let grayscaleFilter = CIFilter(name: "CIPhotoEffectMono")
        grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)

        let ciContext = CIContext()
        if let result = grayscaleFilter?.outputImage,
           let cgImage = ciContext.createCGImage(result, from: result.extent) {
            return cgImage
        }
    }

    return outputImage
}

private func applyEffect(
    _ effect: GifEffect,
    progress: CGFloat,
    image: CGImage,
    size: CGSize,
    context: CGContext
) {

    let center = CGPoint(x: size.width / 2, y: size.height / 2)
    let rect = CGRect(origin: .zero, size: size)

    func draw(alpha: CGFloat = 1.0) {
        context.setAlpha(alpha)
        context.draw(image, in: rect)
    }

    switch effect {
        
    case .none:
        draw()

    case .zoom:
        let scale = 1.0 + 0.05 * progress
        context.translateBy(x: center.x, y: center.y)
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: -center.x, y: -center.y)
        draw()

    case .fade:
        draw(alpha: progress)

    case .slideLeft:
        let offset = size.width * 0.08 * (1 - progress)
        context.translateBy(x: -offset, y: 0)
        draw()

    case .pulse:
        let scale = 1.0 + 0.04 * sin(progress * .pi * 2)
        context.translateBy(x: center.x, y: center.y)
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: -center.x, y: -center.y)
        draw()

    case .wobble:
        let angle = sin(progress * .pi * 2) * 0.04
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: angle)
        context.translateBy(x: -center.x, y: -center.y)
        draw()

    case .bounce:
        let yOffset = abs(sin(progress * .pi)) * 20
        context.translateBy(x: 0, y: -yOffset)
        draw()
    }
}


func downscaleCGImage(
    _ image: CGImage,
    maxDimension: CGFloat
) -> CGImage {

    let width = CGFloat(image.width)
    let height = CGFloat(image.height)
    let maxSide = max(width, height)

    guard maxSide > maxDimension else { return image }

    let scale = maxDimension / maxSide
    let newWidth = Int(width * scale)
    let newHeight = Int(height * scale)

    let colorSpace = image.colorSpace ?? CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = image.bitmapInfo.rawValue

    guard let context = CGContext(
        data: nil,
        width: newWidth,
        height: newHeight,
        bitsPerComponent: image.bitsPerComponent,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: bitmapInfo
    ) else {
        return image
    }

    context.interpolationQuality = .high
    context.draw(image, in: CGRect(x: 0, y: 0,
                                   width: newWidth,
                                   height: newHeight))

    return context.makeImage() ?? image
}

