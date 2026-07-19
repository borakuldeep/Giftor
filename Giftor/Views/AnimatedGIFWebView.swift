//
//  AnimatedGIFView 2.swift
//  Giftor
//
//  Created by Kuldeep Bora on 01.02.26.
//


import SwiftUI
import WebKit

struct AnimatedGIFWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <!doctype html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0">
            <style>
                html, body {
                    margin: 0;
                    padding: 0;
                    width: 100%;
                    height: 100%;
                    background: transparent;
                    overflow: hidden;
                }
                img {
                    width: 100%;
                    height: 100%;
                    object-fit: contain;
                }
            </style>
        </head>
        <body>
            <img src="\(url.lastPathComponent)" />
        </body>
        </html>
        """

        webView.loadHTMLString(
            html,
            baseURL: url.deletingLastPathComponent()
        )
    }
}

