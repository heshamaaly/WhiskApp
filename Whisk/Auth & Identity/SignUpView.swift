//
//  SignUpView.swift
//  Whisk
//
//  Created by Hesham Aly on 3/27/25.
//
import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            
            Spacer()
            
            Image("WhiskLogoCompact") //
                .resizable()
                .scaledToFit()
                .frame(width: 140) // Adjust as needed
            
            Spacer()
            
            Text("Create Account")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
            
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            Button(action: signUp) {
                Text("Sign Up")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
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
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Spacer()
            Spacer()
            Spacer()
        }
        //.padding()
        .padding(.horizontal, 25)
    }
    
    func signUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = ""
                // Account created successfully; dismiss the sign-up view.
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

//PREVIEW FUNCTION
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
