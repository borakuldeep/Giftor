//
//  VideoPickerView.swift
//  Giftor
//
//  Created by Kuldeep Bora on 28.01.26.
//

import SwiftUI
import PhotosUI

struct VideoPickerView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var onPick: (PhotosPickerItem) -> Void
    @State private var selection: PhotosPickerItem?
    /*
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
     
     */

    var body: some View {
        PhotosPicker(
            selection: $selection,
            matching: .videos,
            preferredItemEncoding: .current // fast read of item as it is. no processing
        ) {
            FocusPrimaryButtonStyle {
                FocusPrimaryLabel(
                    title: "Import video",
                    systemImage: "video.fill"
                )
            }
        }
        //.buttonStyle(.borderedProminent)
        .buttonStyle(FocusScaleButtonStyle())
        .frame(
            width: horizontalSizeClass == .regular ? 230 : nil,
            height: horizontalSizeClass == .regular ? 150 : nil
        )
        .tint(.white)
        //.foregroundColor(.black)
        .padding(.horizontal)
        .onChange(of: selection) { newItem in
            if let newItem {
                onPick(newItem)
            }
        }
    }
}

struct PhotoPickerView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var onPick: (PhotosPickerItem) -> Void
    @State private var selection: PhotosPickerItem?

    var body: some View {
        PhotosPicker(
            selection: $selection,
            matching: .images,
            preferredItemEncoding: .current // fast read of item as it is. no processing
        ) {
            FocusPrimaryButtonStyle {
                FocusPrimaryLabel(
                    title: "Import photo",
                    systemImage: "photo.fill"
                )
            }
        }
        .buttonStyle(FocusScaleButtonStyle())
        .frame(
            width: horizontalSizeClass == .regular ? 230 : nil,
            height: horizontalSizeClass == .regular ? 100 : nil
        )
        .tint(.white)
        //.foregroundColor(.black)
        .padding(.horizontal)
        .onChange(of: selection) { newItem in
            if let newItem{
                onPick(newItem)
            }
        }
    }
}



