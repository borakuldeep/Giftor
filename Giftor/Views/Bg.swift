//
//  Bg.swift
//  Giftor
//
//  Created by Kuldeep Bora on 22.02.26.
//


import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

@Observable
final class AppBackground {
    static let shared = AppBackground()
    private init() {}
    
    var color: String = getAppColor()   // default
}

// light bg candidates: #eccbd9,#ffeaec
// dark bg candidates: #222222, #414073, #376996, #2A2A72, #69140E

struct Bg: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Bindable private var bg = AppBackground.shared
    
    func body(content: Content) -> some View {
        ZStack {
            Color(hex: colorScheme == .dark ? bg.color : "#ffeaec")
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func appBackground() -> some View {
        self.modifier(Bg())
    }
}

let defaultColor = "#414073"
func getAppColor() -> String {
    var color: String = defaultColor //default"
    if let currColor = UserDefaults.standard.string(forKey: "appColor") {
        color = currColor
    }
    else {
        UserDefaults.standard.set(color, forKey: "appColor")
    }
    return color
}

func setAppColor() -> String {
    let colors = ["#222222", "#5F00BA", "#404E4D", "#8A3033"]
    var newColor = colors[0]
    let currentColor = getAppColor()
    if currentColor == defaultColor {
        UserDefaults.standard.set(newColor, forKey: "appColor")
    }
    else {
        let index = colors.firstIndex(of: currentColor)
        if index == 3 {
            newColor = defaultColor
        }
        else {
            newColor = colors[index! + 1]
        }
        UserDefaults.standard.set(newColor, forKey: "appColor")
    }
    return newColor
}
