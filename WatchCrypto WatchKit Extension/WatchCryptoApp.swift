//
//  WatchCryptoApp.swift
//  WatchCrypto WatchKit Extension
//
//  Created by Timothy Beers on 3/23/22.
//

import SwiftUI

@main
struct WatchCryptoApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
