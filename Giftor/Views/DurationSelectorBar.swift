//
//  DurationSelectorBar.swift
//  Giftor
//
//  Created by Kuldeep Bora on 27.01.26.
//

import SwiftUI

/// A bar of duration pill buttons (1-5s) followed by a trim bar.
/// Extracted from HomeView to keep the main view cleaner.
struct DurationSelectorBar: View {
    let selectedDuration: Int
    let videoLength: Double

        @Binding var clipStartTime: Double
    var onGifAction: ((Int) -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach([1, 2, 3, 4, 5], id: \.self) { seconds in
                    DurationPill(
                        seconds: seconds,
                        isSelected: selectedDuration == seconds,
                        action: { onGifAction?(seconds) }
                      )
                  }.padding(.bottom)
            }

            GifTrimBar(
                duration: videoLength,
                selectedDuration: selectedDuration,
                clipStartTime: $clipStartTime
              ) {
               if let action = onGifAction {
                   action(selectedDuration)
                 }
              }
              .padding(.horizontal, 4)
        }
    }
}

// MARK: - Individual Duration Pill Button

private struct DurationPill: View {
    let seconds: Int
    let isSelected: Bool
    var action: (() -> Void)?

    var body: some View {
        Button(action: { action?() }) {
            Text("\(seconds)s")
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : .secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(selectedBackground())
                  )
            }
        }

    private func selectedBackground() -> Color {
        isSelected ? Color.purple.opacity(0.85) : Color.gray.opacity(0.2)
      }
}

//#Preview {
//    VStack {
//        DurationSelectorBar(
//            selectedDuration: 3,
//            videoLength: 10.0,
//            clipStartTime: .constant(2.5),
//            onGifAction: { print("Generate") }
//          )
//
//        Color.blue.frame(height: 200).opacity(0.1)
//      }
//        .padding()
//    }
