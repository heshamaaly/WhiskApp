//
//  WhiskApp.swift
//  Whisk
//
//  Created by Hesham Aly on 3/27/25.
//

import SwiftUI
import Firebase

@main
struct WhiskApp: App {
    init () {
        FirebaseApp.configure()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
