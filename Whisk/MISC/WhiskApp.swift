//
//  WhiskApp.swift
//  Whisk
//
//  Created by Hesham Aly on 3/27/25.
//

import SwiftUI
import Firebase
import Combine

@main
struct WhiskApp: App {
    init () {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.debug)
    }
    @StateObject private var linkHandler = LinkHandler()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .onOpenURL { url in
                    linkHandler.handle(url: url)
                }
        }
    }
}
