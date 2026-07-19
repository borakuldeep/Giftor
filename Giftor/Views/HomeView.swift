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
                VStack {
                    ProgressView("Processing…")
                }
            } else if let error = viewModel.errorMessage {
                VStack {
                     Image("AppIconImage")
                          .resizable()
                          .scaledToFit()
                          .frame(width: 120, height: 120)
                          .clipShape(
                             RoundedRectangle(
                                 cornerRadius: 26,
                                 style: .continuous
                              )
                          )
                          .overlay(
                             RoundedRectangle(
                                 cornerRadius: 18,
                                 style: .continuous
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

            else if let url = viewModel.previewURL {
                HStack {
                    // Left
                    HStack {
                        Button("+ New") {
                            viewModel.reset()
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Center
                    Image("AppIconImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 10,
                                style: .continuous
                            )
                        )
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: 10,
                                style: .continuous
                            )
                            .stroke(Color.white, lineWidth: 3)
                        )
                        .shadow(radius: 6)

                    // Right
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white, lineWidth: 8)
                    )

                }
                Spacer()
                if viewModel.selectedItemType == "video" {
                    HStack(spacing: 12) {
                        Spacer()
                        ForEach([1, 2, 3, 4, 5], id: \.self) { seconds in
                            Button {
                                Task {
                                    viewModel.isProcessing = true
                                    viewModel.gifLength = seconds
                                    try await viewModel.generateGif(
                                        asset: viewModel.asset!
                                    )
                                    viewModel.isProcessing = false
                                }
                            } label: {
                                Text("\(seconds)s")
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .foregroundColor(
                                        viewModel.gifLength == seconds
                                            ? .black : .primary
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(
                                                viewModel.gifLength == seconds
                                                    ? .white
                                                    : Color.gray.opacity(0.2)
                                            )
                                    )
                            }
                        }
                        Spacer()
                    }
                    GifTrimBar(
                        duration: viewModel.videoLength,
                        selectedDuration: viewModel.gifLength,
                        clipStartTime: $viewModel.gifStartTime
                    ) {
                        Task {
                            viewModel.isProcessing = true
                            try await viewModel.generateGif(
                                asset: viewModel.asset!
                            )
                            viewModel.isProcessing = false
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom)
                }
                HStack {
                    VStack {

                        Button {
                            Task {
                                await viewModel.export(.gif)
                            }
                        } label: {
                            FocusPrimaryButtonStyle {
                                FocusPrimaryLabel(
                                    title: "Save GIF",
                                    systemImage: "square.and.arrow.down"
                                )
                            }
                        }
                        .buttonStyle(FocusScaleButtonStyle())

                        ShareLink(
                            item: url
                        ) {
                            FocusPrimaryButtonStyle {
                                FocusPrimaryLabel(
                                    title: "Share GIF",
                                    systemImage: "square.and.arrow.up"
                                )
                            }
                        }
                    }

                    VStack {
                        Button {
                            showTextSheet = true
                        } label: {
                            FocusPrimaryButtonStyle {
                                FocusPrimaryLabel(
                                    title: "Edit Text",
                                    systemImage: "character.cursor.ibeam"
                                )
                            }
                        }
                        .buttonStyle(FocusScaleButtonStyle())

                        Button {
                            showSettingSheet = true
                        } label: {
                            FocusPrimaryButtonStyle {
                                FocusPrimaryLabel(
                                    title: "Settings",
                                    systemImage: "gear.badge"
                                )
                            }
                        }
                        .buttonStyle(FocusScaleButtonStyle())
                    }
                }
                .padding(.vertical)
            } else {
                //VideoGifView()
                importButtonView
            }
        }
        .appBackground()
        .overlay(alignment: .bottom) {
            if viewModel.showSavedToast {
                Text(
                    viewModel.isProcessing ? "saving..." : "GIF saved to Photos"
                )
                .font(.subheadline)
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.yellow)
                .clipShape(Capsule())
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 20)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            viewModel.showSavedToast = false
                        }
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
                    //showSettingSheet = false
                    Task {
                        if viewModel.selectedItemType == "video" {
                            try await viewModel.generateGif(
                                asset: viewModel.asset!,
                                settings: draft
                            )
                        } else {
                            try viewModel.regenerateGifFromPhoto(
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
                    showTextSheet = false
                    Task {
                        try viewModel.updateTextOverlay(settings1: draft1, settings2: draft2)
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

    @ViewBuilder
    private var importButtonView: some View {
        VStack(spacing: 28) {
            Image("AppIconImage")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white, lineWidth: 4)
                )
                .shadow(radius: 6)
                .padding(.top, 48)
                .padding(.bottom, 48)

            VStack(spacing: 12) {
                Text("GIFTOR")
                    .font(.largeTitle.bold())

                Text("Create funny gifs from videos and photos")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }

            VideoPickerView { item in
                Task {
                    await viewModel.loadVideo(from: .photos(item))
                }
            }

            PhotoPickerView { item in
                Task {
                    try await viewModel.processImportedPhoto(item: item)
                }
            }

            Spacer()
//            Button(action: {
//                AppBackground.shared.color = setAppColor()
//            }) {
//                Image(systemName: "pencil.tip.crop.circle.fill")
//                    .resizable()
//                    .frame(width: 60, height: 60)
//            }
//            Spacer()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(IAPManager(preview: true))
}
