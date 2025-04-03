//
//  FinalStateView.swift
//  Whisk
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct FinalStateView: View {
    @Binding var userInput: String
    let recipes: [Recipe]
    @Binding var selectedRecipeIndex: Int
    let animation: Namespace.ID
    let onRegenerate: () -> Void
    let isLoading: Bool
    @State private var showAccountSheet = false
    
    var body: some View {
        NavigationView {
            // Wrap the entire content in a ZStack so that we can overlay the loading view.
            ZStack {
                // Base content: All final-state content is scrollable.
                ScrollView {
                    VStack(spacing: 16) {
                        //Logo
                        //Image("WhiskLogo")
                        //   .resizable()
                        //   .scaledToFit()
                        //   .frame(width: 100, height: 80) // Adjust as needed
                        
                        // Add some top spacing if needed.
                        Spacer().frame(height: 5)
                        
                        // Input view at the top.
                        ExpandableInputView(text: $userInput) {
                            onRegenerate()
                        }
                        .frame(maxWidth: 350)
                        .matchedGeometryEffect(id: "textBox", in: animation)
                        .padding(.bottom, 45)
                        .zIndex(1)
                        
                        // If there are multiple recipes, display a horizontal pill selector.
                        // If there are multiple recipes, display a horizontal pill selector.
                        if recipes.count > 1 {
                            ZStack(alignment: .trailing) {
                                // 1) Horizontal scroll view of pills
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(recipes.indices, id: \.self) { index in
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
                                                    .background(selectedRecipeIndex == index ? Color.accentColor : Color(.clear))
                                                    .cornerRadius(16)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.top)
                                }
                                
                                // 2) Fade gradient overlay on the trailing edge
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.clear, Color.white]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(width: 30)                // Adjust width for how much fade you want
                                .allowsHitTesting(false)         // Ensure taps pass through to the pills
                            }
                            
                            // Subtle grey line below the pills
                            Divider()
                                .padding(.horizontal)
                        }
                        
                        // Display the selected recipe details using RecipeCardView.
                        RecipeCardView(recipe: recipes[selectedRecipeIndex])
                            .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .blur(radius: isLoading ? 10 : 0)
                
                // Overlay: If isLoading is true, show a loading indicator.
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
            //FinalState Toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("WhiskLogoCompact")
                     .resizable()
                     .scaledToFit()
                     .frame(width: 40, height: 40)
                     
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAccountSheet = true }) {
                        Image(systemName: "person.fill")
                            .foregroundStyle(Color.black)
                    }
                }
            }
            .sheet(isPresented: $showAccountSheet) {
                AccountView() }
        }
    
        // Animate changes to isLoading.
        .animation(.easeInOut(duration: 0.5), value: isLoading)
    }
}


// Preview

struct FinalStateView_Previews: PreviewProvider {
    @Namespace static var animation
    
    static var sampleRecipe = Recipe(
        recipeId: nil,
        title: "Classic Caesar Salad 🥗",
        text: "A traditional Caesar salad featuring crisp romaine, creamy dressing, crunchy croutons, and Parmesan cheese.",
        ingredients: [
            "2 romaine lettuce hearts",
            "1/2 cup Caesar dressing",
            "1/2 cup grated Parmesan cheese",
            "1 cup croutons",
            "2 tablespoons olive oil",
            "1 clove garlic, minced",
            "Salt and pepper to taste",
            "2 anchovy fillets (optional)",
            "Lemon wedges for serving"
        ],
        instructions: [
            "Wash and dry the romaine lettuce, then tear into bite-sized pieces.",
            "Toss the lettuce with Caesar dressing until evenly coated.",
            "Heat olive oil in a pan, sauté garlic (and anchovies if desired) until aromatic.",
            "Top with croutons and Parmesan cheese.",
            "Season with salt and pepper.",
            "Serve with lemon wedges."
        ],
        mealType: "",
        timestamp: nil,
        isFavorite: false
    )
    
    static var previews: some View {
        Group {
            // Preview with a single recipe
            FinalStateView(
                userInput: .constant("High protein dinner ideas"),
                recipes: [sampleRecipe],
                selectedRecipeIndex: .constant(0),
                animation: animation,
                onRegenerate: { print("Regenerate tapped") },
                isLoading: false
            )
            .previewDisplayName("Final State - Single Recipe")
            
            // Preview with multiple recipes, second recipe selected.
            FinalStateView(
                userInput: .constant("High protein dinner ideas"),
                recipes: [sampleRecipe, sampleRecipe, sampleRecipe],
                selectedRecipeIndex: .constant(1),
                animation: animation,
                onRegenerate: { print("Regenerate tapped") },
                isLoading: false
            )
            .previewDisplayName("Final State - Multiple Recipes")
        }
    }
}
