//
//  FocusPrimaryButton.swift
//  Giftor
//
//  Created by Kuldeep Bora on 13.02.26.
//

import SwiftUI

struct FocusPrimaryButtonStyle<Content: View>: View {
    
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
              .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
              // Material Design 3 Style: Flat Surface Shape (Rounded Rectangle)
              .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                      .fill(Color(UIColor.systemBackground)) 
              )
              // Pink Border Addition
              .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                      .stroke(Color.pink, lineWidth: 3.5)
              )
              // M3 Elevation Shadow: Smooth drop shadow simulating physical elevation
              .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
      }
}

struct FocusScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
              .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
              .opacity(configuration.isPressed ? 0.88 : 1.0)
              .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
      }
}

struct FocusPrimaryLabel: View {
    
    let title: String
    let systemImage: String?
    
    var body: some View {
        HStack(spacing: 8) {
            
            if let systemImage {
                Image(systemName: systemImage)
                      .font(.system(size: 16, weight: .semibold))
              }
            
            Text(title)
                  .font(.system(size: 16, weight: .medium)) // M3 prefers Medium/System over heavy tracking bumps
                  .tracking(0.5)                           // Updated to match M3 tighter typography
          }
          .foregroundStyle(.primary)
      }
}

