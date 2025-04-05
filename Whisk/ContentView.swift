//
//  ContentView.swift
//  Whisk
//
//  Created by Hesham Aly on 3/27/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isUserLoggedIn = false

    var body: some View {
        NavigationStack {
            Group {
                if isUserLoggedIn {
                    MainTabView()
                } else {
                    GetStartedView(
                        onGoogleSignIn: { /* Implement Google sign-in action */ },
                        onAppleSignIn: { /* Implement Apple sign-in action */ }
                        // If your GetStartedView also supports other actions (like onGetStarted or onLogin),
                        // pass those closures here as needed.
                    )
                }
            }
            .onAppear {
                // Check if a user is already signed in and listen for auth state changes.
                self.isUserLoggedIn = Auth.auth().currentUser != nil
                Auth.auth().addStateDidChangeListener { _, user in
                    self.isUserLoggedIn = (user != nil)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
