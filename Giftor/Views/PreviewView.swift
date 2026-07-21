//
//  PreviewView.swift
//  Giftor
//
//  Created by Kuldeep Bora on 28.01.26.
//


import SwiftUI
import QuickLook

struct PreviewView: View {

    let url: URL
     @State private var quickLookURL: URL?

    var body: some View {
         VStack(spacing: 16) {
            if url.pathExtension.lowercased() == "gif" {
                AnimatedGIFWebView(url: url)

             } else {
                Button("Preview HEIC") {
                    quickLookURL = url
                 }
                  .buttonStyle(.plain)
                  .foregroundStyle(.white)
                  .padding()
                  .background(
                    LinearGradient(
                       colors: [.purple.opacity(0.85), .pink.opacity(0.85)],
                        startPoint: .topLeading,
                         endPoint: .bottomTrailing
                       ),
                      in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                   )
                    .shadow(color: .purple.opacity(0.35), radius: 6, y: 4)
               }
         }
          .padding(20)
          .background(
             RoundedRectangle(cornerRadius: 20, style: .continuous)
                  .fill(.ultraThinMaterial.opacity(0.5))
              .overlay(
                 RoundedRectangle(cornerRadius: 20, style: .continuous)
                       .strokeBorder(
                          LinearGradient(
                              colors: [.purple.opacity(0.6), .pink.opacity(0.6)],
                               startPoint: .topLeading,
                                endPoint: .bottomTrailing
                             ),
                            lineWidth: 2
                          )
                    )
        )
     }
}

#Preview {
    let url = Bundle.main.url(forResource: "Sample", withExtension: "GIF")!
     //let path = Bundle.main.path(forResource: "Sample", ofType:"GIF")!
     PreviewView(url: url)
}
