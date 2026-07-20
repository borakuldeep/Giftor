//
//  BottomActions.swift
//  Giftor
//
//  Created by Kuldeep Bora on 27.01.26.
//

import SwiftUI

/// The two-column bottom action bar: Save/Share on left, Edit/Settings on right.
struct BottomActions: View {
    let previewURL: URL
    @Binding var showTextSheet: Bool
    @Binding var showSettingSheet: Bool
    let onExport: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Button {
                    Task { onExport() }
                } label: {
                    FocusPrimaryButtonStyle {
                        FocusPrimaryLabel(
                            title: "Save GIF",
                            systemImage: "square.and.arrow.down"
                        )
                    }
                }
                .buttonStyle(FocusScaleButtonStyle())

                ShareLink(item: previewURL) {
                    FocusPrimaryButtonStyle {
                        FocusPrimaryLabel(
                            title: "Share GIF",
                            systemImage: "square.and.arrow.up"
                        )
                    }
                }
                .buttonStyle(FocusScaleButtonStyle())
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
    }
}
