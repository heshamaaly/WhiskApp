//
//  LoginView.swift
//  Whisk
//
//  Created by Hesham Aly on 3/27/25.
//
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showSignUp = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to Whisk!")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Button(action: signIn) {
                    Text("Sign In")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Navigation link to the sign-up view
                NavigationLink(destination: SignUpView(), isActive: $showSignUp) {
                    Button("Don't have an account? Sign Up") {
                        showSignUp = true
                    }
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
    }
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = ""
                // Proceed to the main app view after successful sign in.
                // This is where you'd typically update your app's state to show the main content.
            }
        }
    }
}

