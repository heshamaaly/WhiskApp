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
    @State private var isSigningIn = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image("WhiskLogoCompact") //
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140) // Adjust as needed
                Spacer()
                Text("Sign In")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                
                Button(action: {
                    isSigningIn = true
                    signIn()
                }) {
                    if isSigningIn {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(12)
                            .shadow(
                                color: Color(red: 1.0, green: 192/255, blue: 0.0).opacity(0.8),
                                radius: 25,
                                x: 0,
                                y: 4.34
                            )
                    }}
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                Spacer()
                    
                    Button("Don't have an account? Sign Up") {
                        showSignUp = true
                    }
                    .padding(.bottom, 20)
                    .foregroundColor(.black)
                }
                .padding()
                .padding(.horizontal, 25)
                .navigationDestination(isPresented: $showSignUp) {
                    SignUpView()
                }
            }
        }
    
        
        
        //Sign in Funciton
        func signIn() {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                DispatchQueue.main.async {
                    isSigningIn = false
                }
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    errorMessage = ""
                    // Sign in succeeded – dismiss the LoginView.
                    DispatchQueue.main.async {
                        dismiss()  // This dismisses the LoginView, allowing navigation to the main view.
                    }
                }
            }
        }
    }
    
    // Preview Function
    
    struct LoginView_Previews: PreviewProvider {
        static var previews: some View {
            LoginView()
        }
    }

