//
//  SettingsSheetView.swift
//  Giftor
//
//  Created by Kuldeep Bora on 07.02.26.
//

import SwiftUI

struct SettingsDraft: Equatable {
    var gifLength: Int
    var gifFps: Int
    var gifEffect: GifEffect
    var gifPlaybackSpeed: Double
    var gifQuality: GifQuality
    var gifDirection: String
    var isGifColored: Bool
    var waterMark: String
    var endFrame: String
}

struct SettingsSheetView: View {
     @Environment(\.dismiss) var dismiss
     @EnvironmentObject var iapManager: IAPManager
     @State var draft: SettingsDraft

    let itemType: String    // video or photo
    
     // Auto-save is handled by the .onChange modifier below, 
     // eliminating the need for a manual Save button!
    let onSave: (_ draft: SettingsDraft) -> Void
    
     @State private var showAutoSaveToast = false
     @State private var debounceTask: Task<Void, Never>?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                      // Radio Selection (Picker with Inline Style)
                    if itemType != "video" {    // only for image
                        Section(header: Text("Effects")) {
                            Picker(
                                selection: $draft.gifEffect,
                                label: EmptyView()
                              ) {
                                ForEach(GifEffect.allCases) { effect in
                                    Text(effect.rawValue).tag(effect)
                                 }
                              }
                              .pickerStyle(.inline)    // Makes it look like a radio list
                          }
                      }

                    if itemType == "video" {
                        Section(
                            header: Text("Frames per second"),
                            footer: Text(
                                  "Higher fps will produce large size gifs"
                              )
                          ) {
                            Picker(
                                selection: $draft.gifFps,
                                label: EmptyView()
                              ) {
                                Text("8 fps").tag(8)
                                Text("10 fps").tag(10)
                                Text("12 fps").tag(12)
                              }
                              .pickerStyle(.inline)    // Makes it look like a radio list

                          }

                      }

                    Section(
                        header: Text("Resolution"),
                        footer: Text(
                              "Higher resolution will produce large size gifs"
                          )
                      ) {
                        Picker(
                            selection: $draft.gifQuality,
                            label: EmptyView()
                          ) {
                            Text("Low").tag(GifQuality.Low)
                            Text("Medium").tag(GifQuality.Medium)
                            Text("High").tag(GifQuality.High)
                          }
                          .pickerStyle(.segmented)    // Great for 2-3 options

                      }

                      // Font Size Selection (Segmented Style)
                    Section(header: Text("Playback speed")) {    // paid feature
                        Picker(
                              "Select playback speed",
                            selection: $draft.gifPlaybackSpeed
                          ) {
                            Text("1x").tag(1.0)
                            Text("2x").tag(2.0)
                              //Text("3x").tag(12)
                          }
                          .pickerStyle(.segmented)    // Great for 2-3 options

                      }

                      // End frames
                    Section(
                        header: Text("End frame"),
                        footer: Text("End gif with black or white frame")
                      ) {    // paid feature
                        Picker(
                              "Select end frames color",
                            selection: $draft.endFrame
                          ) {
                            Text("Black").tag("black")
                            Text("White").tag("white")
                            Text("None").tag("None")
                          }
                          .pickerStyle(.segmented)    // Great for 2-3 options

                      }

                      // add more paid feature - B&W gifs, colored Texts, Last frame of video B&W and zoom in
                    if itemType == "video" {    // paid feature
                        Section(header: Text("Playback direction")) {
                            Picker(
                                  "Select playback speed",
                                selection: $draft.gifDirection
                              ) {
                                Text("Forward").tag("fwd")
                                Text("Reverse").tag("rev")
                                  //Text("3x").tag(12)
                              }
                              .pickerStyle(.segmented)    // Great for 2-3 options

                          }
                      }

                    Section(
                        header: Text("Gif Color"),
                      ) {
                        Picker(
                            selection: $draft.isGifColored,
                            label: EmptyView()
                          ) {
                            Text("Colored").tag(true)
                            Text("B&W").tag(false)
                          }
                          .pickerStyle(.segmented)

                      }

                    Section(header: Text("Change water mark")) {
                        if ["free", "plus"].contains(iapManager.userPaidStatus)
                          {
                            Text("Available for Pro users only.")
                          } else {
                            TextField(draft.waterMark, text: $draft.waterMark)
                          }
                      }
                      .opacity(iapManager.userPaidStatus == "pro" ? 1.0 : 0.5)

                  }
                  .scrollContentBackground(.hidden)
              }
              .navigationTitle("Settings")
              .navigationBarTitleDisplayMode(.inline)
              .toolbar {
                  Button("Close") {
                      dismiss()
                  }
              }
             
             // Auto-save toast overlay replaces the manual Save button! 
             // Simply swipe down from bottom to dismiss the sheet.
            .overlay(alignment: .bottom) {
                 if showAutoSaveToast {
                     Text(
                          "Updated!"
                      )
                      .font(.system(size: 14, weight: .semibold))
                      .foregroundStyle(.primary)
                      .padding(.horizontal, 20)
                      .padding(.vertical, 12)
                      .background(Color.green.opacity(0.85), in: RoundedRectangle(cornerRadius: 16))
                      .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                  }
              }
              .animation(.easeInOut, value: showAutoSaveToast) // Smooth fade out after 1 sec

             // Trigger auto-saving toast whenever draft changes
               .onChange(of: draft) { _, newValue in
                debounceTask?.cancel()
                
                 // Show toast immediately
                 withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                     showAutoSaveToast = true
                  }
                 
                 debounceTask = Task {
                    try? await Task.sleep(for: .seconds(1.0)) // Matches your 1-second toast request exactly
                    guard !Task.isCancelled else { return }
                     
                     // Hide toast and trigger the actual background regeneration logic
                     showAutoSaveToast = false
                    onSave(newValue)
                  }
              }

              .appBackground()
          }
      }
}
