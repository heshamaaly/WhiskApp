import SwiftUI
import FirebaseAuth

struct AccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showResetAlert = false
    @State private var resetErrorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = Auth.auth().currentUser {
                    Text("Signed in as \(user.email ?? "Unknown")")
                        .font(.headline)
                }

                // Reset Password
                Button("Reset Password") {
                    resetPassword()
                }
                .buttonStyle(.borderedProminent)

                // Sign Out
                Button("Sign Out") {
                    signOut()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)

                Spacer()
            }
            .padding()
            .navigationTitle("Account")
            // Done button in the navigation bar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showResetAlert) {
                Alert(
                    title: Text("Password Reset"),
                    message: Text(resetErrorMessage ?? "Check your email for reset instructions."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func resetPassword() {
        guard let email = Auth.auth().currentUser?.email else { return }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                resetErrorMessage = "Error: \(error.localizedDescription)"
            } else {
                resetErrorMessage = nil
            }
            showResetAlert = true
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            // Dismiss this view after signing out
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
