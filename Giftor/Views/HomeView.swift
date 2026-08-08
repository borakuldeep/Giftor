//
//  HomeView.swift
//  Giftor
//
//  Created by Kuldeep Bora on 27.01.26.
//

import PhotosUI
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var iapManager: IAPManager
    @State private var viewModel = VideoToGIFViewModel()
    @State private var showTextSheet = false
    @State private var showSettingSheet = false
    @State private var showMenuSheet = false

    var body: some View {
        VStack {
            if viewModel.isProcessing, viewModel.previewURL == nil {
                ProcessingLogoView()
            } else if let error = viewModel.errorMessage {
                errorView(error: error)
            } else if let url = viewModel.previewURL {
                previewContentView(url: url)
                    .padding(10)
            } else {
                EmptyStateView(viewModel: viewModel)
            }
        }
        .appBackground()
        .overlay(alignment: .bottom) {
            if viewModel.showSavedToast {
                Text(
                    viewModel.isProcessing ? "saving..." : "Saved to Photos"
                )
                .font(.subheadline)
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.green.opacity(0.85), in: RoundedRectangle(cornerRadius: 16))
                .clipShape(Capsule())
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 20)
                .onAppear {
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(2))
                        viewModel.showSavedToast = false
                    }
                }
            }
        }
        .animation(.easeInOut, value: viewModel.showSavedToast)
        .fullScreenCover(
            isPresented: $showSettingSheet,
            content: {
                SettingsSheetView(
                    draft: SettingsDraft(
                        gifLength: viewModel.gifLength,
                        gifFps: viewModel.gifFps,
                        gifEffect: viewModel.photoGifEffect,
                        gifPlaybackSpeed: viewModel.gifPlaybackSpeed,
                        gifQuality: viewModel.gifQuality,
                        gifDirection: viewModel.gifDirection,
                        isGifColored: viewModel.isGifColored,
                        waterMark: viewModel.waterMark,
                        endFrame: viewModel.gifEndFrameColor
                    ),
                    itemType: viewModel.selectedItemType
                ) { draft in
                    Task {
                        if viewModel.selectedItemType == "video" {
                            try? await viewModel.generateGif(
                                asset: viewModel.asset!,
                                settings: draft
                            )
                        } else {
                            try? viewModel.regenerateGifFromPhoto(
                                settings: draft
                            )
                        }
                    }
                }
            }
        )
        .fullScreenCover(
            isPresented: $showTextSheet,
            content: {
                TextSheetView(
                    draft: TextOverlayDraft(
                        text: viewModel.gifText,
                        textPosition: viewModel.textPosition,
                        textSize: viewModel.textSize,
                        isBlinking: viewModel.gifTextBlink,
                        textColor: viewModel.gifTextColor,
                        textTiming: viewModel.textPlacement
                    ),
                    draft2Initial: TextOverlayDraft(
                        text: viewModel.gifText2,
                        textPosition: viewModel.text2Position,
                        textSize: viewModel.text2Size,
                        isBlinking: viewModel.gifText2Blink,
                        textColor: viewModel.gifText2Color,
                        textTiming: viewModel.text2Placement
                    )
                ) { draft1, draft2 in
                    Task {
                        try? viewModel.updateTextOverlay(
                            settings1: draft1,
                            settings2: draft2
                        )
                    }
                }
            }
        )
        .fullScreenCover(
            isPresented: $showMenuSheet,
            content: {
                BuyProductView()
            }
        )
    }

    // MARK: - Error View
    @ViewBuilder
    private func errorView(error: String) -> some View {
        VStack(spacing: 0) {
            Image("AppIconImage")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 26, style: .continuous
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: 18, style: .continuous
                    )
                    .stroke(Color(hex: "#F093FB"), lineWidth: 4)
                )
                .shadow(color: .purple.opacity(0.25), radius: 8, y: 6)
                .padding(.bottom, 48)

            Text(error)
                .foregroundStyle(Color(red: 0.95, green: 0.35, blue: 0.4))
                .font(.system(size: 18, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 44)

            Button {
                viewModel.reset()
            } label: {
                FocusPrimaryButtonStyle {
                    FocusPrimaryLabel(
                        title: "GO AGAIN",
                        systemImage: "arrow.counterclockwise"
                    )
                }
            }
            .buttonStyle(FocusScaleButtonStyle())
        }
    }

    // MARK: - Preview Content View
    @ViewBuilder
    private func previewContentView(url: URL) -> some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                Button("+ New") {
                    viewModel.reset()
                  }
                  .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                  .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                  .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

                Image("AppIconImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 10, style: .continuous
                        )
                    )
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 10, style: .continuous
                        )
                        .stroke(Color.white, lineWidth: 3)
                    )
                    .shadow(radius: 6)

                HStack {
                    Button(action: {
                        showMenuSheet = true
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.headline)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)
            .padding(.vertical)

            GeometryReader { geo in
                VStack {
                    if viewModel.isProcessing {
                        ProgressView("Processing…")
                            .frame(maxWidth: .infinity)
                    } else {
                        PreviewView(url: url)
                    }
                }
                .frame(height: geo.size.height)
            }

            Spacer()

if viewModel.selectedItemType == "video" {
                DurationSelectorBar(
                    selectedDuration: viewModel.gifLength,
                    videoLength: viewModel.videoLength,
                    clipStartTime: $viewModel.gifStartTime,
                    onGifAction: { seconds in
                        Task {
                            viewModel.isProcessing = true
                            viewModel.gifLength = seconds
                            try? await viewModel.generateGif(
                                asset: viewModel.asset!
                            )
                            viewModel.isProcessing = false
                        }
                    }
                   )
                   .padding(.bottom)
             }

            BottomActions(
                previewURL: url,
                showTextSheet: $showTextSheet,
                showSettingSheet: $showSettingSheet
             ) { Task { await viewModel.export() } }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(IAPManager(preview: true))
}

struct ProcessingLogoView: View {
    @State private var rotationAngle: Double = 0

    var body: some View {
        VStack(spacing: 20) {
            Image("AppIconImage")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(.rect(cornerRadius: 22))
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }

            Text("Processing…")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}
