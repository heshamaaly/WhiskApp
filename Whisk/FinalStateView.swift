//
//  FinalStateView.swift
//  Whisk
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct FinalStateView: View {
    @Binding var userInput: String
    let recipeTitle: String
    let recipeDescription: String
    let recipeIngredients: [String]
    let recipeInstructions: [String]
    let animation: Namespace.ID
    let onRegenerate: () -> Void
    let isLoading: Bool      // NEW: Pass in the loading state

    var body: some View {
        // Wrap the entire content in a ZStack so that we can overlay the loading view.
        ZStack {
            // Base content: All final-state content is scrollable.
            ScrollView {
                VStack(spacing: 16) {
                    // Optional: Some top space if needed.
                    Spacer().frame(height: 10)
                    
                    // Input view at the top with regeneration action.
                    ExpandableInputView(text: $userInput) {
                        onRegenerate()
                    }
                    .frame(maxWidth: 350)
                    .matchedGeometryEffect(id: "textBox", in: animation)
                    .padding(.bottom, 40)
                    .zIndex(1)     // ensure it appears above recipe content
                    
                    // Recipe content section.
                    if !recipeTitle.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            // Recipe Title Section.
                            Text(recipeTitle)
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                            
                            // Recipe Description.
                            Text(recipeDescription)
                                .font(.body)
                                .foregroundColor(Color(red: 127/255, green: 127/255, blue: 127/255))
                                .padding(.horizontal)
                            
                            // Ingredients & Cooking Instructions Section.
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Ingredients 📝")
                                    .font(.title2)
                                    .bold()
                                ForEach(recipeIngredients, id: \.self) { ingredient in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                        Text(ingredient)
                                            .font(.body)
                                    }
                                }
                                
                                Divider()
                                    .padding(.vertical, 8)
                                
                                Text("Cooking Instructions 👨‍🍳")
                                    .font(.title2)
                                    .bold()
                                ForEach(recipeInstructions, id: \.self) { instruction in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                        Text(instruction)
                                            .font(.body)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    Spacer(minLength: 20)
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
            // Apply a blur to the base content when loading.
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
        // Animate changes to isLoading.
        .animation(.easeInOut(duration: 0.5), value: isLoading)
    }
}
