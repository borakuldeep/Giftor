//
//  PreviewView.swift
//  Giftor
//
//  Created by Kuldeep Bora on 28.01.26.
//


import SwiftUI

struct PreviewView: View {
    let url: URL

    var body: some View {
        AnimatedGIFWebView(url: url)
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
                                lineWidth: 6
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
