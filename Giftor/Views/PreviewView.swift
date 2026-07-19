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
        //GeometryReader { geo in
            VStack(spacing: 12) {
                if url.pathExtension.lowercased() == "gif" {
                    AnimatedGIFWebView(url: url)
                    
                } else {
                    Button("Preview HEIC") {
                        quickLookURL = url
                    }
                }
            }
            //.frame(height: geo.size.height * 2 / 3)
            //.quickLookPreview($quickLookURL)
        //}
    }
}

#Preview {
    let url = Bundle.main.url(forResource: "Sample", withExtension: "GIF")!
    //let path = Bundle.main.path(forResource: "Sample", ofType:"GIF")!
    PreviewView(url: url)
}
