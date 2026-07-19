//
//  GiftorApp.swift
//  Giftor
//
//  Created by Kuldeep Bora on 26.01.26.
//

import SwiftUI

@main
struct GiftorApp: App {

    @StateObject var iapManager = IAPManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await iapManager.restorePurchases()
                }
        }
        .environmentObject(iapManager)
    }
}
