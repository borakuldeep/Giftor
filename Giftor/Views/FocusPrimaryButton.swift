//
//  FocusPrimaryButton.swift
//  Giftor
//
//  Created by Kuldeep Bora on 13.02.26.
//


import SwiftUI

struct FocusPrimaryButtonStyle1<Content: View>: View {
    
    let content: Content
    var width: CGFloat
    var height: CGFloat
    
    init(
        width: CGFloat = 150,
        height: CGFloat = 56,
        @ViewBuilder content: () -> Content
    ) {
        self.width = width
        self.height = height
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(width: width, height: height)
            .background(
                ZStack {
                    Color.white
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.15),
                    radius: 8,
                    x: 0,
                    y: 4)
    }
}

struct FocusScaleButtonStyle1: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct FocusPrimaryLabel1: View {
    
    let title: String
    let systemImage: String?
    
    var body: some View {
        HStack(spacing: 8) {
            
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
            }
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .tracking(3)
        }
        .foregroundStyle(.black)
    }
}
