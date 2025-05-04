//
//  LinkHandler.swift
//  Whisk
//
//  Created by Hesham Aly on 4/16/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore            // Firestore, FieldValue, Decoder

final class LinkHandler: ObservableObject {
    private let db = Firestore.firestore()

    /// Handle whisk://share?id=<docID> deep‑links
    func handle(url: URL) {
        // Parse the custom‑scheme URL
        guard url.scheme == "whisk",
              url.host   == "share",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let recipeID  = components.queryItems?
                    .first(where: { $0.name == "id" })?.value
        else { return }

        // Must be signed in
        guard let user = Auth.auth().currentUser else {
            NotificationCenter.default.post(name: .showAuthAlert, object: nil)
            return
        }

        // 1) Fetch the shared recipe doc
        db.collection("sharedRecipes").document(recipeID).getDocument { [weak self] snapshot, error in
            guard let self = self,
                  error == nil,
                  var data = snapshot?.data()
            else { return }

            // 2) Decode BEFORE inserting FieldValue
            guard var recipe = try? Firestore.Decoder().decode(Recipe.self, from: data)
            else { return }
            recipe.id = recipeID                       // carry the doc ID into the model

            // 3) Stamp a fresh timestamp so it sorts to the top
            data["timestamp"] = FieldValue.serverTimestamp()

            // 4) Save into the receiver’s /users/{uid}/recipes collection
            self.db.collection("users").document(user.uid)
                .collection("recipes").document(recipeID)
                .setData(data, merge: true) { writeErr in
                    guard writeErr == nil else { return }

                    // 5) Notify HomeView with the full Recipe object
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .openSharedRecipe,
                                                        object: recipe)
                    }
                }
        }
    }
}

// MARK: - Notification keys
extension Notification.Name {
    static let openSharedRecipe = Notification.Name("openSharedRecipe")
    static let showAuthAlert    = Notification.Name("showAuthAlert")
}
