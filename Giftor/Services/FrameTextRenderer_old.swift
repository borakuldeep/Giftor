//
//  FrameTextRenderer_old.swift
//  Giftor
//
//  Created by Kuldeep Bora on 30.01.26.
//  Original UIKit/UIGraphicsImageRenderer implementation.
//

//import UIKit
//import SwiftUI
//
//enum TextColorOption: CaseIterable, Identifiable {
//    case red, black, yellow, white
//    
//    var id: Self { self }
//    
//    var uiColor: UIColor {
//        switch self {
//        case .red: return .red
//        case .black: return .black
//        case .yellow: return .yellow
//        case .white: return .white
//        }
//    }
//    
//    var color: Color {
//        Color(uiColor)
//    }
//}
//
//enum FrameTextRenderer_old {
//    
//    static func drawText(
//        _ text: String,
//        onto image: CGImage,
//        position: TextPosition = .top,
//        size textSize: TextSize = .small,
//        opacity: CGFloat = 1.0,
//        color: TextColorOption = .white,   // ✅ New parameter
//        waterMark: String = "GIFTOR"
//    ) -> CGImage {
//
//        let size = CGSize(width: image.width, height: image.height)
//        let renderer = UIGraphicsImageRenderer(size: size)
//
//        let renderedImage = renderer.image { context in
//            UIImage(cgImage: image).draw(in: CGRect(origin: .zero, size: size))
//
//            let baseFontSize = size.width * 0.06
//            let fontSize = textSize == .large ? baseFontSize * 3 : textSize == .medium ? baseFontSize * 2 : baseFontSize
//
//            let font: UIFont = textSize == .large
//                ? UIFont.boldSystemFont(ofSize: fontSize)
//                : UIFont.systemFont(ofSize: fontSize)
//
//            let horizontalPadding = size.width * 0.05
//            let verticalPadding = size.height * 0.05
//            let maxTextWidth = size.width - (horizontalPadding * 2)
//
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.alignment = position == .bottomLeft ? .left : .center
//            paragraphStyle.lineBreakMode = .byWordWrapping
//
//            let textColor = color.uiColor.withAlphaComponent(opacity)
//
//            // 🔹 Calculate bounding rect without stroke first
//            let baseAttributes: [NSAttributedString.Key: Any] = [
//                .font: font,
//                .paragraphStyle: paragraphStyle
//            ]
//
//            let boundingRect = text.boundingRect(
//                with: CGSize(width: maxTextWidth, height: .greatestFiniteMagnitude),
//                options: [.usesLineFragmentOrigin, .usesFontLeading],
//                attributes: baseAttributes,
//                context: nil
//            )
//
//            let textHeight = ceil(boundingRect.height)
//
//            let textRect: CGRect = {
//                switch position {
//                case .top:
//                    return CGRect(
//                        x: horizontalPadding,
//                        y: verticalPadding,
//                        width: maxTextWidth,
//                        height: textHeight
//                    )
//                case .middle:
//                    return CGRect(
//                        x: horizontalPadding,
//                        y: (size.height - textHeight) / 2,
//                        width: maxTextWidth,
//                        height: textHeight
//                    )
//                case .bottom, .bottomLeft:
//                    return CGRect(
//                        x: horizontalPadding,
//                        y: size.height - textHeight - verticalPadding,
//                        width: maxTextWidth,
//                        height: textHeight
//                    )
//                }
//            }()
//
//            if !text.isEmpty {
//                let attributedText = NSMutableAttributedString(string: text)
//
//                attributedText.addAttributes([
//                    .font: font,
//                    .foregroundColor: textColor,
//                    .paragraphStyle: paragraphStyle,
//                    .strokeColor: UIColor.white.withAlphaComponent(opacity),
//                    .strokeWidth: -1.0 // Negative = fill + stroke
//                ], range: NSRange(location: 0, length: attributedText.length))
//
//                attributedText.draw(in: textRect)
//            }
//
//            // Paragraph style
//            let logoStyle = NSMutableParagraphStyle()
//            logoStyle.alignment = .left
//            logoStyle.lineBreakMode = .byWordWrapping
//
//            let logoFont = UIFont.systemFont(ofSize: baseFontSize)
//
//            let logoAttributes: [NSAttributedString.Key: Any] = [
//                .font: logoFont,
//                .foregroundColor: UIColor.white.withAlphaComponent(0.4),
//                .paragraphStyle: logoStyle
//            ]
//
//            // Measure actual text size
//            let constraintRect = CGSize(width: maxTextWidth, height: .greatestFiniteMagnitude)
//            let boundingBox = waterMark.boundingRect(
//                with: constraintRect,
//                options: [.usesLineFragmentOrigin, .usesFontLeading],
//                attributes: logoAttributes,
//                context: nil
//            )
//
//            let logoHeight = ceil(boundingBox.height)
//
//            // Fixed bottom padding
//            let bottomPadding: CGFloat = 20
//
//            // Final rect (locked to bottom)
//            let logoRect = CGRect(
//                x: horizontalPadding,
//                y: size.height - bottomPadding - logoHeight,
//                width: maxTextWidth,
//                height: logoHeight
//            )
//
//            waterMark.draw(in: logoRect, withAttributes: logoAttributes)
//        }
//
//        return renderedImage.cgImage!
//    }
//}
