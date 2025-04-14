//
//  FinalStateView.swift
//  Whisk
//
//  Created by [Your Name] on [Date].
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FinalStateView: View {
    @Binding var userInput: String
    @Binding var recipes: [Recipe]           // Changed from a constant to a binding to allow mutation
    @Binding var selectedRecipeIndex: Int
    let animation: Namespace.ID
    let onRegenerate: () -> Void
    let isLoading: Bool
    @State private var showAccountSheet = false
    @Binding var isRecipeGenerated: Bool
    
    // Extracted expanded input view to simplify the view hierarchy
    private var expandedInputView: some View {
        let view = ExpandableInputView(
            text: $userInput,
            onSubmit: { onRegenerate() },
            showClearButton: true,
            onClear: { userInput = "" }
        )
        return AnyView(
            view
                .padding(.horizontal, 60)
                .matchedGeometryEffect(id: "textBox", in: animation)
                .padding(.bottom, 45)
                .zIndex(1)
        )
    }
    
    // Extract a single recipe button to reduce complexity in the ForEach closure.
    private func recipeButton(for index: Int) -> some View {
        Button(action: {
            withAnimation {
                selectedRecipeIndex = index
            }
        }) {
            Text(recipes[index].title)
                .font(selectedRecipeIndex == index ? .subheadline.bold() : .subheadline)
                .foregroundColor(selectedRecipeIndex == index ? .white : .black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .background(
            Group {
                if selectedRecipeIndex == index {
                    Color.accentColor
                } else {
                    // Use a clear view and then apply the ultra-thin material background.
                    Color.clear
                        .background(.ultraThinMaterial)
                }
            }
        )
        .cornerRadius(16)
    }
    
    // Extracted horizontal recipe pill selector into its own view,
    // now using the recipeButton helper for each index.
    private var recipePillSelector: some View {
        ZStack(alignment: .trailing) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(recipes.indices, id: \.self) { index in
                        recipeButton(for: index)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            
            // Fade gradient overlay on the trailing edge.
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.white]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 30)
            .allowsHitTesting(false)
        }
    }
    
    // Simplified scrollable content by breaking the view into subviews.
    private var scrollViewContent: some View {
        AnyView(
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 2)
                    
                    // Input view at the top, extracted.
                    expandedInputView
                    
                    // If there are multiple recipes, display a horizontal pill selector.
                    if recipes.count > 1 {
                        recipePillSelector
                        
                        Divider()
                            .padding(.horizontal)
                    }
                    
                    // Display the selected recipe details using RecipeCardView.
                    RecipeCardView(recipe: recipes[selectedRecipeIndex]) { recipe in
                        toggleFavorite(recipe)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
        )
    }
    
    var body: some View {
        ZStack {
            scrollViewContent
                .blur(radius: isLoading ? 10 : 0)
            
            // Loading overlay.
            if isLoading {
                VStack {
                    ProgressView("Loading new recipe...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.3))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    withAnimation {
                        isRecipeGenerated = false
                        userInput = ""  // Clear the text input.
                    }
                }) {
                    Image("WhiskLogoCompact")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAccountSheet = true }) {
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.black)
                }
            }
        }
        .sheet(isPresented: $showAccountSheet) {
            AccountView()
        }
        .animation(.easeInOut(duration: 0.5), value: isLoading)
    }
    
    /// Toggle the favorite status of a recipe. This function updates the local state immediately (so the star toggles color)
    /// and then performs an update in Firestore.
    private func toggleFavorite(_ recipe: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        let newStatus = !recipes[index].isFavorite
        recipes[index].isFavorite = newStatus  // Immediate UI update
        
        // Update Firestore with the new favorite status.
        guard let user = Auth.auth().currentUser, let docId = recipe.id else {
            print("Unable to toggle favorite: no user logged in or recipe id is missing.")
            return
        }
        Firestore.firestore().collection("users").document(user.uid)
            .collection("recipes").document(docId)
            .updateData(["isFavorite": newStatus]) { error in
                if let error = error {
                    print("Error updating Firestore: \(error.localizedDescription)")
                } else {
                    print("Updated favorite=\(newStatus) for recipe \(recipe.title) in Firestore.")
                }
            }
    }
}

// MARK: - Preview
struct FinalStateView_Previews: PreviewProvider {
    @Namespace static var animation
    static var sampleRecipe: Recipe = Recipe(
        recipeId: "sample123",
        title: "Classic Caesar Salad 🥗",
        text: "A refreshing salad featuring crisp romaine, crunchy croutons, and tangy Parmesan cheese.",
        totalTime: "30 minutes",
        servings: "4",
        ingredients: [
            "All": [
                "2 romaine lettuce hearts",
                "1/2 cup Caesar dressing",
                "1/2 cup grated Parmesan cheese",
                "1 cup croutons"
            ]
        ],
        instructions: [
            "All": [
                "Wash and dry the romaine lettuce, then tear into bite-size pieces.",
                "Toss lettuce with Caesar dressing until evenly coated.",
                "Top with croutons and grated Parmesan cheese."
            ]
        ],
        tips: [
            "All": [
                "For extra protein, add grilled chicken.",
                "Try kale for a twist."
            ]
        ],
        mealType: "Salad",
        timestamp: nil,
        isFavorite: false
    )
    
    static var previews: some View {
        Group {
            NavigationView {
                FinalStateView(
                    userInput: .constant("Healthy Caesar Salad"),
                    recipes: .constant([sampleRecipe]),
                    selectedRecipeIndex: .constant(0),
                    animation: animation,
                    onRegenerate: { print("Regenerate tapped") },
                    isLoading: false,
                    isRecipeGenerated: .constant(true)
                )
            }
            .previewDisplayName("Final State - Single Recipe")
            
            NavigationView {
                FinalStateView(
                    userInput: .constant("Healthy dinner ideas"),
                    recipes: .constant([sampleRecipe, sampleRecipe, sampleRecipe]),
                    selectedRecipeIndex: .constant(1),
                    animation: animation,
                    onRegenerate: { print("Regenerate tapped") },
                    isLoading: false,
                    isRecipeGenerated: .constant(true)
                )
            }
            .previewDisplayName("Final State - Multi Recipe")
        }
    }
}
