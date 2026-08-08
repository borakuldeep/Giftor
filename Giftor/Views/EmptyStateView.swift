//
//  EmptyStateView.swift
//  Giftor - Initial import screen
//

import PhotosUI
import SwiftUI

/// Screen shown when no content has been imported yet.
/// Contains app icon, title, and picker buttons.
struct EmptyStateView: View {
    let viewModel: VideoToGIFViewModel
    @State private var emojisFloating = false

    private let emojiSpots: [(emoji: String, x: CGFloat, y: CGFloat)] = [
        ("🎈", -130, -100),
        ("🪄", 135, -140),
        ("✨", 150, 55),
        ("🤪", -140, 75),
        ("🎉", 0, 205),
    ]

    var body: some View {
        VStack(spacing: 28) {
            // App icon surrounded by playful floating emojis
            ZStack {
                ForEach(emojiSpots, id: \.emoji) { spot in
                    Text(spot.emoji)
                        .font(.system(size: 36))
                        .offset(x: spot.x, y: spot.y + (emojisFloating ? -14 : 0))
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 2.2)
                                    .repeatForever(autoreverses: true)
                            ) {
                                emojisFloating = true
                            }
                        }
                }

                Image("AppIconImage")
                    .resizable().scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(.rect(cornerRadius: 26, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white, lineWidth: 4)
                    )
                    .shadow(color: .purple.opacity(0.35), radius: 12, y: 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Title
            VStack(spacing: 12) {
                Text("Time to get goofy! 🎉")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text("Giftor turns your videos & photos into hilarious GIFs. Pick one to start!")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .fontDesign(.rounded)

            // Picker buttons
            VideoPickerView { item in
                Task { await viewModel.loadVideo(from: .photos(item)) }
            }
            PhotoPickerView { item in
                Task { try await viewModel.processImportedPhoto(item: item) }
            }

            Spacer()
        }
    }
}
