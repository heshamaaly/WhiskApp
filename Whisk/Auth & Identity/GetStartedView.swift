//
//  GetStartedView.swift
//  Whisk
//
//  Created by Hesham Aly on 4/4/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn



struct GetStartedView: View {
    // Callback actions for buttons:
    //let onGetStarted: () -> Void
    let onGoogleSignIn: () -> Void
    let onAppleSignIn: () -> Void
    @State private var showSignUp = false
    @State private var showLogin = false
    //let onLogin: () -> Void
    
    var body: some View {
        ZStack {
            // 1) Full-screen Hero Image (Vegetables)
            Image("VegetableBackground") // Replace with your actual image name
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // 2) Full-screen White Fade Overlay
            Image("ProtectionLayer") // Replace with your actual fade image name
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                
            // 3) Main Content
            VStack(spacing: 16) {
                //Spacer(minLength: 50)
                
                // Whisk Logo
                Image("WhiskLogoCompact") // Replace with your actual logo name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140) // Adjust as needed
                
                Spacer()
                
                // Header Text Field (Main Title)
                Text("Unleash Your Inner Chef")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                
                // Sub Header Text Field
                Text("Generate easy, healthy, and personalized recipes in seconds.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    
                
                //Spacer()
                
                // 4) Buttons
                VStack(spacing: 30) { // increased vertical spacing from 12 to 20
                    HStack(spacing: 18) { // increased horizontal spacing between Google and Apple buttons
                        // Google CTA
                        Button(action: onGoogleSignIn) {
                            HStack {
                                Image("GLogo") // Replace with your actual Google logo asset
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Google")
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 14) // reduced vertical padding for a smaller button height
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                        }
                        
                        // Apple CTA
                        Button(action: onAppleSignIn) {
                            HStack {
                                Image(systemName: "apple.logo") // Replace with your actual Apple logo asset
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Apple")
                                    .fontWeight(.medium)
                            }
                            .padding(.vertical, 14) // reduced vertical padding for a smaller button height
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                        }
                    }
                    
                    // Get Started CTA
                    // Get Started CTA
                    Button(action: {
                        withAnimation {
                            showSignUp = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(15)
                            .shadow(
                                color: Color(red: 1.0, green: 192/255, blue: 0.0).opacity(0.8),
                                radius: 25,
                                x: 0,
                                y: 4.34
                            )
                    }
                }
                
                .padding(.top)
                //Spacer()
                
                // 5) "Already have an account? Login"
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    Button(action: {
                        withAnimation {
                            showLogin = true
                        }
                    }) {
                        Text("Login")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                }
                .padding(.bottom, 60)
                .padding(.top, 40)
            
            }
            
            .padding(.top, 65)
            .padding(.horizontal, 60)
            
            // Hidden NavigationLinks for programmatic navigation
                NavigationLink(destination: SignUpView(), isActive: $showSignUp) {
                EmptyView()
                        }
                NavigationLink(destination: LoginView(), isActive: $showLogin) {
                EmptyView()
                            }
        }
    }
}

// Google Sign-in Handling
func handleGoogleSignIn() {
    // Ensure the Firebase clientID is available.
    guard let clientID = FirebaseApp.app()?.options.clientID else {
        print("Missing Firebase clientID")
        return
    }
    
    // Create a Google Sign-In configuration object.
    let config = GIDConfiguration(clientID: clientID)
    
    // Retrieve the root view controller from the current window.
    guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
        print("Unable to get rootViewController")
        return
    }
    
    // Initiate Google Sign-In using the updated API.
    GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, hint: nil, additionalScopes: []) { result, error in
        if let error = error {
            print("Error during Google Sign-In: \(error.localizedDescription)")
            return
        }
        
        guard let result = result else {
            print("Error retrieving sign-in result")
            return
        }
        
        let user = result.user
        
        // Extract the tokens using the tokenString property.
        guard let idTokenString = user.idToken?.tokenString else {
            print("Error retrieving id token")
            return
        }
        let accessTokenString = user.accessToken.tokenString
        
        // Create a Firebase credential using the Google tokens.
        let credential = GoogleAuthProvider.credential(withIDToken: idTokenString, accessToken: accessTokenString)
        
        // Sign in with Firebase.
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("Firebase sign in error: \(error.localizedDescription)")
            } else {
                print("Successfully signed in with Google!")
            }
        }
    }
}

// MARK: - Preview
struct GetStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GetStartedView(
            onGoogleSignIn: { print("Google tapped") },
            onAppleSignIn: { print("Apple tapped") }
        )
        .previewDisplayName("GetStartedView")
    }
}
