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
    
    var body: some View {
        VStack(spacing: 28) {
            // App icon
            Image("AppIconImage")
                    .resizable().scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                              .stroke(Color.white, lineWidth: 4)
                   )
                    .shadow(radius: 6)
                    .padding(.top, 48).padding(.bottom, 48)

            // Title
            VStack(spacing: 12) {
                Text("GIFTOR").font(.largeTitle.bold())
                Text("Create funny gifs from videos and photos")
                       .multilineTextAlignment(.center)
                       .foregroundColor(.white)
              }
            
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