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
import AuthenticationServices
import CryptoKit



struct GetStartedView: View {
    // Callback actions for buttons:
    //let onGetStarted: () -> Void
    let onGoogleSignIn: () -> Void
    let onAppleSignIn: () -> Void
    @State private var showSignUp = false
    @State private var showLogin = false
    //Apple Sign In
    @StateObject private var appleSignInCoordinator = SignInWithAppleCoordinator()
    
    var body: some View {
        ZStack {
            // 1) Full-screen Hero Image (Vegetables)
            Image("VegetableBackground") // Replace with your actual image name
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // 2) Full-screen White Fade Overlay
            Image("ProtectionLayer")
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
                        
                        // Sign-in with Apple CTA
                        Button(action: {
                            appleSignInCoordinator.startSignInWithAppleFlow()
                        }) {
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
        .onAppear {
            appleSignInCoordinator.onSignInSuccess = onAppleSignIn
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

// Sign in with Apple Function

final class SignInWithAppleCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding, ObservableObject {
    
    // This will hold the nonce so that it is available when the Apple sign-in callback fires.
    var currentNonce: String?
    
    // New completion callback for successful sign in
    var onSignInSuccess: (() -> Void)?
    
    /// Initiates Sign in with Apple.
    func startSignInWithAppleFlow() {
        // Generate a random nonce.
        let nonce = randomNonceString()
        currentNonce = nonce
        
        // Create an Apple ID request.
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        
        // Request full name and email from the user.
        request.requestedScopes = [.fullName, .email]
        // Set the hashed nonce.
        request.nonce = sha256(nonce)
        
        // Create and perform the authorization controller.
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - ASAuthorizationControllerDelegate methods
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                print("Invalid state: no nonce was set")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to retrieve or serialize Apple identity token")
                return
            }
            
            // Create a Firebase credential using the Apple ID token and nonce.
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign in error: \(error.localizedDescription)")
                } else {
                    print("Successfully signed in with Apple and Firebase!")
                    // Invoke the completion callback to update the UI
                    DispatchQueue.main.async {
                        self.onSignInSuccess?()
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple failed: \(error.localizedDescription)")
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Return the key window of the application.
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
    
    // MARK: - Helper methods
    
    /// Generates a random nonce string.
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with error: \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random) % charset.count])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    /// Hashes input using SHA256.
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
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
