//
//  RecipeCardView.swift
//  Whisk
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RecipeCardView: View {
    let recipe: Recipe
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
        VStack(alignment: .leading, spacing: 16) {
            // Recipe Title Section
            HStack(alignment: .top) {
                Text(recipe.title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                    .padding(.horizontal)
                
                Spacer()
                Spacer()
                
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
                .padding(.trailing, 25)
                .padding(.top, 12)
            }
            .background(Color.white)
            
            // 2) Description Section
            Text(recipe.text)
                .font(.body)
                .foregroundColor(Color(red: 127/255, green: 127/255, blue: 127/255))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
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
            .padding(.horizontal, 15)
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
            .padding(.horizontal, 7)
        }
        
    }
}

// Helper for adding Favorite Button
extension RecipeCardView {
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
}



//Preview

struct RecipeCardView_Previews: PreviewProvider {
    static var sampleRecipe: Recipe = Recipe(
        recipeId: nil,
        title: "Classic Caesar Salad 🥗",
        text: "A refreshing salad featuring crisp romaine, crunchy croutons, and tangy Parmesan cheese.",
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
                "Try kale for a different twist."
            ]
        ],
        mealType: "Salad",
        timestamp: nil,
        isFavorite: false
    )
    
    static var previews: some View {
        RecipeCardView(recipe: sampleRecipe)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
