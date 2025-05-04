//
//  RecipeDetailView.swift
//  Whisk
//
//  Created by Hesham Aly on 3/29/25.
//

import SwiftUI
import UIKit
import FirebaseAuth
import FirebaseFirestore

struct RecipeDetailView: View {
    let recipe: Recipe
    
    @State private var showShareOptions = false

    private var ingredientOrder: [String] {
        if let groups = recipe.ingredients {
            return recipe.ingredientsOrder ?? Array(groups.keys)
        }
        return []
    }

    private var instructionOrder: [String] {
        if let groups = recipe.instructions {
            return recipe.instructionsOrder ?? Array(groups.keys)
        }
        return []
    }

    private var tipOrder: [String] {
        if let groups = recipe.tips {
            return recipe.tipsOrder ?? Array(groups.keys)
        }
        return []
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 1) Title Section
                HStack(alignment: .top) {
                    Text(recipe.title)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.black)
                        .padding(.leading, 30)
                    
                    Spacer()
                    Spacer(minLength: 20)
                    
                    Button(action: {
                        // Call your favorite toggle function.
                        toggleFavorite(recipe)
                        // Provide haptic feedback
                        hapticFeedback()
                    }) {
                        Image(systemName: recipe.isFavorite ? "star.fill" : "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(recipe.isFavorite ? .yellow : .brandGray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                    
                    // Share button
                    Button(action: {
                        showShareOptions = true          // <-- open our option sheet
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 30)
                    .padding(.top, 12)
                }
                .background(Color.white)
                
                
                
                // 2) Description Section
                Text(recipe.text)
                    .font(.body)
                    .foregroundColor(Color(red: 127/255, green: 127/255, blue: 127/255))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)

                // HStack for total time & servings
                HStack(spacing: 16) {
                    // Total Time
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.gray)
                        Text(recipe.totalTime ?? "N/A")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 127/255, green: 127/255, blue: 127/255))
                    }
                    
                    // Thin vertical line
                    Divider()
                        .frame(width: 1, height: 20)
                        .background(Color.gray.opacity(0.4))
                    
                    // Servings
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.gray)
                        Text("Serves: \(recipe.servings ?? "N/A")")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 127/255, green: 127/255, blue: 127/255))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading) // <-- Added this line to left-align the section
                .padding(.horizontal, 30)
                .padding(.bottom, 8)
                
                // Ingredients & Cooking Instructions Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Ingredients 📝")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let ingredientsGroups = recipe.ingredients {
                        ForEach(ingredientOrder, id: \.self) { group in
                            if group != "All" {
                                Text(group)
                                    .font(.headline)
                                    .padding(.top, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            ForEach(ingredientsGroups[group] ?? [], id: \.self) { ingredient in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                    Text(ingredient)
                                        .font(.body)
                                }
                            }
                        }
                    } else {
                        Text("No ingredients available.")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                
                // Cooking Instructions
                    Text("Cooking Instructions 👨‍🍳")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let instructionsGroups = recipe.instructions, !instructionsGroups.isEmpty {
                        ForEach(instructionOrder, id: \.self) { group in
                            if group != "All" {
                                Text(group)
                                    .font(.headline)
                                    .padding(.top, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            ForEach(instructionsGroups[group] ?? [], id: \.self) { step in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                    Text(step)
                                        .font(.body)
                                }
                            }
                        }
                    } else {
                        Text("No instructions available.")
                             .font(.body)
                             .foregroundColor(.gray)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)

                    // Tips Section
                    Text("Tips 💡")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let tipsGroups = recipe.tips {
                        ForEach(tipOrder, id: \.self) { group in
                            if group != "All" {
                                Text(group)
                                    .font(.headline)
                                    .padding(.top, 4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            ForEach(tipsGroups[group] ?? [], id: \.self) { tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                    Text(tip)
                                        .font(.body)
                                }
                            }
                        }
                    } else {
                        Text("No tips available.")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 2)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 8)
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Share Recipe",
                            isPresented: $showShareOptions,
                            titleVisibility: .visible) {
            Button("Send as Picture") {
                shareRecipeAsPNG()
            }
            Button("Send as Whisk Recipe") {
                shareRecipeAsLink()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

 


// MARK: - Parsing Logic

/// A naive parser that splits `text` into three parts:
/// 1) Everything before "Ingredients:" → description
/// 2) Lines between "Ingredients:" and "Cooking Instructions:" → ingredients
/// 3) Lines after "Cooking Instructions:" → instructions
private func parseRecipeText(_ text: String) -> (description: String, ingredients: [String], instructions: [String]) {
    // We’ll look for these markers (case-sensitive)
    let ingredientsMarker = "Ingredients:"
    let instructionsMarker = "Cooking Instructions:"
    
    // If neither marker is found, just treat the entire text as a description
    guard let ingRange = text.range(of: ingredientsMarker) else {
        return (text, [], [])
    }
    // If no instructions marker is found, treat everything after "Ingredients:" as ingredients
    guard let instrRange = text.range(of: instructionsMarker) else {
        let description = String(text[..<ingRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        let ingredientsBlock = String(text[ingRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        let ingredientsArray = ingredientsBlock
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        return (description, ingredientsArray, [])
    }
    
    // Split into three sections
    let description = text[..<ingRange.lowerBound]
    let ingredientsBlock = text[ingRange.upperBound..<instrRange.lowerBound]
    let instructionsBlock = text[instrRange.upperBound...]
    
    // Convert them to strings
    var descString = String(description).trimmingCharacters(in: .whitespacesAndNewlines)
    descString = descString.replacingOccurrences(of: "Description:\n", with: "")
    descString = descString.replacingOccurrences(of: "Description:", with: "")
    let ingString = String(ingredientsBlock).trimmingCharacters(in: .whitespacesAndNewlines)
    let instrString = String(instructionsBlock).trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Convert the block into arrays (split by newline)
    let ingredientsArray = ingString
        .components(separatedBy: .newlines)
        .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    let instructionsArray = instrString
        .components(separatedBy: .newlines)
        .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    
    return (descString, ingredientsArray, instructionsArray)
}

extension RecipeDetailView {
    private func toggleFavorite(_ recipe: Recipe) {
        // Ensure you have a valid user and recipe id before attempting a toggle.
        guard let user = Auth.auth().currentUser,
              let docId = recipe.id else {
            print("Cannot toggle favorite: Missing user or recipe id")
            return
        }
        
        let newFavoriteStatus = !recipe.isFavorite
        Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .collection("recipes")
            .document(docId)
            .updateData(["isFavorite": newFavoriteStatus]) { error in
                if let error = error {
                    print("Error updating favorite: \(error.localizedDescription)")
                } else {
                    print("Successfully updated favorite status to \(newFavoriteStatus) for recipe: \(recipe.title)")
                }
            }
        
        // Haptic feedback for user interaction
        hapticFeedback()
    }
    
    private func hapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
//MARK: - Sharing Functions
    
    //SHARE AS PNG
    /// Capture the current window as a PNG and present the share sheet
    private func shareRecipeAsPNG() {
        // 1) Create a snapshot of just the recipe content
        let snapshotView = RecipeSnapshotView(recipe: recipe)
        let hosting = UIHostingController(rootView: snapshotView)

        // Give it a fitting width (minus your horizontal padding) and let height size itself
        let width = UIScreen.main.bounds.width - 40
        let targetSize = hosting.sizeThatFits(in: CGSize(width: width, height: .infinity))
        hosting.view.bounds = CGRect(origin: .zero, size: targetSize)

        // 2) Render that hosting controller to a UIImage
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let image = renderer.image { _ in
            hosting.view.drawHierarchy(in: hosting.view.bounds, afterScreenUpdates: true)
        }

        // 3) Present the native share sheet directly
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        // On iPad you must set a sourceView; on iPhone it will default to a bottom pull-up
        activityVC.popoverPresentationController?.sourceView = UIApplication.shared.windows
            .first { $0.isKeyWindow }
        if let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            root.present(activityVC, animated: true, completion: nil)
        }
    }
    
    //Share as URL
    private func shareRecipeAsLink() {
        // ensure doc id
        guard let recipeID = recipe.id else { return }

        // copy to /sharedRecipes (read‑only public collection)
        let db = Firestore.firestore()
        guard let data = try? Firestore.Encoder().encode(recipe) else { return }
        db.collection("sharedRecipes").document(recipeID).setData(data) { _ in
            if let url = URL(string: "whisk://share?id=\(recipeID)") {
                let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                    root.present(vc, animated: true)
                }
            }
        }
    }
    
}


// Preview function

struct RecipeDetailView_Previews: PreviewProvider {
    static var sampleRecipe: Recipe {
        return Recipe(
            recipeId: "sample123",
            title: "Classic Caesar Salad 🥗",
            text: "A refreshing salad featuring crisp romaine, crunchy croutons, and tangy Parmesan.",
            totalTime: "30 minutes",
            servings: "4",
            ingredients: [
                "Dressing": [
                    "1/2 cup Caesar dressing",
                    "1 clove garlic, minced"
                ],
                "Salad": [
                    "2 romaine lettuce hearts",
                    "1 cup croutons",
                    "1/4 cup grated Parmesan cheese"
                ]
            ],
            instructions: [
                "Preparation": [
                    "Wash and dry the romaine lettuce, then tear into bite-size pieces."
                ],
                "Assembly": [
                    "Toss lettuce with Caesar dressing until evenly coated.",
                    "Top with croutons and grated Parmesan cheese."
                ]
            ],
            tips: [
                "Variations": [
                    "For extra protein, add grilled chicken.",
                    "For a twist, try kale instead of romaine."
                ]
            ],
            mealType: "Salad",
            timestamp: nil, // Let Firestore assign the timestamp
            isFavorite: false
        )
    }

    // Favorite CTA
    private func toggleFavorite(_ recipe: Recipe) {
        // Flip the favorite flag. (This is a placeholder; adapt as needed.)
        // In a production app, you might update Firestore here.
        // For instance:
        guard let user = Auth.auth().currentUser, let docId = recipe.id else { return }
        let newFavoriteStatus = !recipe.isFavorite
        Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .collection("recipes")
            .document(docId)
            .updateData(["isFavorite": newFavoriteStatus]) { error in
                if let error = error {
                    print("Error updating favorite: \(error.localizedDescription)")
                }
            }
        
        // Optionally, trigger haptic feedback.
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    
    
    
    static var previews: some View {
        NavigationView {
            RecipeDetailView(recipe: sampleRecipe)
        }
    }
}
