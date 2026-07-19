//
//  GifTrimBar.swift
//  Giftor
//
//  Created by Kuldeep Bora on 01.02.26.
//

import SwiftUI

let trimBarHeight: CGFloat = 50

struct GifTrimBar: View {
    let duration: Double
    let selectedDuration: Int
    @Binding var clipStartTime: Double

    let onSeek: () -> Void
    @State private var isScrubbing = false

    let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        let durationInt = Int(duration)
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: trimBarHeight)
                ZStack(alignment: .leading) {
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                .white
                            )
                            .frame(
                                width: selectionWidth(
                                    totalWidth: geo.size.width
                                ),
                                height: trimBarHeight
                            )
                            .offset(
                                x: selectionOffset(totalWidth: geo.size.width)
                            )
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        //beforeSeek()
                                        if !isScrubbing {
                                            isScrubbing = true
                                            haptic.prepare()
                                            haptic.impactOccurred()
                                        }
                                        updateStartTime(
                                            dragX: value.location.x,
                                            totalWidth: geo.size.width
                                        )
                                        
                                    }
                                    .onEnded { _ in
                                        isScrubbing = false
                                        onSeek()
                                    }
                            )

                    }
                }
                HStack {
                    Spacer()
                    Text("\(durationInt)s").font(.footnote.bold()).padding(
                        .trailing,
                        6
                    ).offset(y: 12)
                }
            }
            .contentShape(Rectangle()) // makes whole bar tappable
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            updateStartTime(
                                dragX: value.location.x,
                                totalWidth: geo.size.width
                            )
                            onSeek()

                            // update audio/video here
                        }
                )
        }
        .frame(height: trimBarHeight)
    }

    // MARK: - Helpers

    private func selectionWidth(totalWidth: CGFloat) -> CGFloat {
        guard duration > 0 else { return 0 }
        return totalWidth
            * min(
                CGFloat(selectedDuration) / CGFloat(duration),
                1
            )
    }

    private func selectionOffset(totalWidth: CGFloat) -> CGFloat {
        let maxOffset = totalWidth - selectionWidth(totalWidth: totalWidth)
        let maxStart = max(duration - Double(selectedDuration), 0.01)
        return CGFloat(clipStartTime / maxStart) * maxOffset
    }

    @discardableResult
    private func updateStartTime(
        dragX: CGFloat,
        totalWidth: CGFloat
    ) -> Double {
        let maxOffset = totalWidth - selectionWidth(totalWidth: totalWidth)
        let clamped = max(0, min(dragX, maxOffset))
        let ratio = clamped / max(maxOffset, 1)

        let newStart =
            ratio * max(duration - Double(selectedDuration), 0)

        clipStartTime = newStart
        return newStart
    }
}
