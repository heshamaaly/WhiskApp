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
    @Binding var isRecipeGenerated: Bool
    
    var body: some View {
            // Wrap the entire content in a ZStack so that we can overlay the loading view.
            ZStack {
                // Base content: All final-state content is scrollable.
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // Add some top spacing if needed.
                        Spacer().frame(height: 2)
                        
                        // Input view at the top.
                        ExpandableInputView(text: $userInput, onSubmit: {
                            onRegenerate()
                        }, showClearButton: true, onClear: {
                            userInput = ""
                        })
                        
                        .padding(.horizontal, 60)
                        //.scaleEffect(0.8) // Shrinks the entire view to 80%
                        //.frame(maxWidth: 350)
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
                    Button(action: {
                            withAnimation {
                                isRecipeGenerated = false
                                userInput = ""  // Clear the text input
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
                AccountView() }
    
        // Animate changes to isLoading.
        .animation(.easeInOut(duration: 0.5), value: isLoading)
    }
}



// Preview
struct FinalStateView_Previews: PreviewProvider {
    @Namespace static var animation

    static var sampleRecipe: Recipe = Recipe(
        recipeId: nil,
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
            // Preview with a single recipe
            NavigationView {
                FinalStateView(
                    userInput: .constant("Healthy Caesar Salad"),
                    recipes: [sampleRecipe],
                    selectedRecipeIndex: .constant(0),
                    animation: animation,
                    onRegenerate: { print("Regenerate tapped") },
                    isLoading: false,
                    isRecipeGenerated: .constant(true)
                )
            }
            .previewDisplayName("Final State - Single Recipe")
            
            // Preview with multiple recipes (3 recipes)
            NavigationView {
                FinalStateView(
                    userInput: .constant("Healthy dinner ideas"),
                    recipes: [sampleRecipe, sampleRecipe, sampleRecipe],
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

