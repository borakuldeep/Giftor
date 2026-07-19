//
//  FrameTextRenderer.swift (Core Graphics/Core Text)
//  Giftor
//
//  Created by Kuldeep Bora on 30.01.26.
//  Rewritten to avoid UIKit/UIGraphicsImageRenderer so it can run off the main thread.
// Bonus - the file sizes are way smaller than older version

import CoreGraphics
import CoreText
import SwiftUI

enum TextColorOption: CaseIterable, Identifiable {
    case red, black, yellow, white
    
    var id: Self { self }
    
    var uiColor: UIColor {
        switch self {
        case .red: return .red
        case .black: return .black
        case .yellow: return .yellow
        case .white: return .white
        }
    }
    
    var color: Color {
        Color(uiColor)
    }
}


// Helper to get a CTFont matching your size/weight choices
private func ctFont(for textSize: TextSize, baseFontSize: CGFloat) -> CTFont {
    // Scale according to your previous logic
    let fontSize: CGFloat
    switch textSize {
    case .small:
        fontSize = baseFontSize
    case .medium:
        fontSize = baseFontSize * 2.0
    case .large:
        fontSize = baseFontSize * 3.0
    }

    // Use bold face for "large" to mimic previous bold behavior
    let fontName: CFString = (textSize == .large)
        ? "HelveticaNeue-Bold" as CFString
        : "HelveticaNeue" as CFString

    // Fallback to system font if the named font fails
    let font = CTFontCreateWithName(fontName, fontSize, nil)
    return font
}

private func cgColor(from option: TextColorOption, alpha: CGFloat = 1.0) -> CGColor {
    Color(option.uiColor.withAlphaComponent(alpha)).cgColor!
}

private func makeAttributedString(
    text: String,
    font: CTFont,
    fillColor: CGColor,
    strokeColor: CGColor,
    strokeWidth: CGFloat,
    alignment: CTTextAlignment
) -> NSAttributedString {

    let paragraphStyle = NSMutableParagraphStyle()
    // Map CTTextAlignment to NSTextAlignment
    switch alignment {
    case .left: paragraphStyle.alignment = .left
    case .center: paragraphStyle.alignment = .center
    case .right: paragraphStyle.alignment = .right
    default: paragraphStyle.alignment = .natural
    }
    paragraphStyle.lineBreakMode = .byWordWrapping

    let attrs: [NSAttributedString.Key: Any] = [
        .font: font as Any,
        .foregroundColor: fillColor,
        NSAttributedString.Key(kCTStrokeWidthAttributeName as String): -abs(strokeWidth),
        NSAttributedString.Key(kCTStrokeColorAttributeName as String): strokeColor,
        .paragraphStyle: paragraphStyle
    ]
    return NSAttributedString(string: text, attributes: attrs)
}

private func boundingSize(for attributed: NSAttributedString, maxWidth: CGFloat) -> CGSize {
    let framesetter = CTFramesetterCreateWithAttributedString(attributed as CFAttributedString)
    let constraint = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
    let suggested = CTFramesetterSuggestFrameSizeWithConstraints(
        framesetter,
        CFRange(location: 0, length: attributed.length),
        nil,
        constraint,
        nil
    )
    return CGSize(width: ceil(suggested.width), height: ceil(suggested.height))
}

// Draws attributed string into rect, handling the Core Text flip locally
private func drawAttributedString(
    _ attributed: NSAttributedString,
    in context: CGContext,
    rect: CGRect
) {
    // Flip locally to draw Core Text upright within a bottom-left origin bitmap
    context.saveGState()
    //context.translateBy(x: rect.minX, y: rect.minY + rect.height)
    context.translateBy(x: rect.minX, y: rect.minY)
    //context.scaleBy(x: 1, y: -1)
    

    let path = CGMutablePath()
    path.addRect(CGRect(origin: .zero, size: rect.size))

    let framesetter = CTFramesetterCreateWithAttributedString(attributed as CFAttributedString)
    let frame = CTFramesetterCreateFrame(
        framesetter,
        CFRange(location: 0, length: attributed.length),
        path,
        nil
    )

    CTFrameDraw(frame, context)
    context.restoreGState()
}

enum FrameTextRenderer {

    static func drawText(
        _ text: String,
        onto image: CGImage,
        position: TextPosition = .top,
        size textSize: TextSize = .small,
        opacity: CGFloat = 1.0,
        color: TextColorOption = .white,
        waterMark: String
    ) -> CGImage {

        let width = image.width
        let height = image.height

        guard let colorSpace = image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB) else {
            return image
        }

        // Create a bitmap context (no global flips)
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return image
        }

        // Draw the base image with the context's default coordinates (bottom-left origin)
        context.draw(image, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))

        let canvasSize = CGSize(width: width, height: height)
        let baseFontSize = canvasSize.width * 0.06
        let font = ctFont(for: textSize, baseFontSize: baseFontSize)

        let horizontalPadding = canvasSize.width * 0.05
        let verticalPadding = canvasSize.height * 0.05
        let maxTextWidth = canvasSize.width - (horizontalPadding * 2)

        // Alignment
        let alignment: CTTextAlignment = (position == .bottomLeft) ? .left : .center

        // Colors
        let fillColor = cgColor(from: color, alpha: opacity)
        let strokeColor = Color.white.opacity(Double(opacity)).cgColor!

        // Draw main text (if any)
        if !text.isEmpty {
            let attributed = makeAttributedString(
                text: text,
                font: font,
                fillColor: fillColor,
                strokeColor: strokeColor,
                strokeWidth: 1.0,
                alignment: alignment
            )

            let measured = boundingSize(for: attributed, maxWidth: maxTextWidth)
            let textHeight = measured.height

            // Compute rect in bottom-left coordinates
            let textRect: CGRect
            switch position {
            case .top:
                // Visual top: high y value in bottom-left coordinates
                textRect = CGRect(
                    x: horizontalPadding,
                    y: canvasSize.height - verticalPadding - textHeight,
                    width: maxTextWidth,
                    height: textHeight
                )
            case .middle:
                textRect = CGRect(
                    x: horizontalPadding,
                    y: (canvasSize.height - textHeight) / 2,
                    width: maxTextWidth,
                    height: textHeight
                )
            case .bottom, .bottomLeft:
                textRect = CGRect(
                    x: horizontalPadding,
                    y: verticalPadding,
                    width: maxTextWidth,
                    height: textHeight
                )
            }

            drawAttributedString(attributed, in: context, rect: textRect)
        }

        // Watermark drawing (fixed near visual bottom, bottom-left coordinates)
        if waterMark != "" {
            let logoFont = CTFontCreateWithName("HelveticaNeue" as CFString, baseFontSize, nil)
            let wmFill = Color.white.opacity(0.4).cgColor!
            let wmAttributed = NSAttributedString(
                string: waterMark,
                attributes: [
                    .font: logoFont,
                    .foregroundColor: wmFill,
                    .paragraphStyle: {
                        let p = NSMutableParagraphStyle()
                        p.alignment = .left
                        p.lineBreakMode = .byWordWrapping
                        return p
                    }()
                ]
            )
            
            let wmConstraint = CGSize(width: maxTextWidth, height: .greatestFiniteMagnitude)
            let wmSize = boundingSize(for: wmAttributed, maxWidth: wmConstraint.width)
            
            // Fixed padding from the visual bottom
            let bottomPadding: CGFloat = 20
            
            let wmRect = CGRect(
                x: horizontalPadding,
                y: bottomPadding,
                width: maxTextWidth,
                height: wmSize.height
            )
            
            drawAttributedString(wmAttributed, in: context, rect: wmRect)
        }

        return context.makeImage() ?? image
    }
}
