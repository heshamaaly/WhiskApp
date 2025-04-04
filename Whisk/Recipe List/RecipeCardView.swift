//
//  RecipeCardView.swift
//  Whisk
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Recipe Title Section
            Text(recipe.title)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
                .padding()
                .background(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Recipe Description Section
            Text(recipe.text)
                .font(.body)
                .foregroundColor(Color(red: 127/255, green: 127/255, blue: 127/255))
                .padding(.horizontal)
            
            // Ingredients & Cooking Instructions Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Ingredients 📝")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let ingredientsGroups = recipe.ingredients {
                    ForEach(Array(ingredientsGroups.keys.sorted()), id: \.self) { group in
                        // Only show the group header if it isn't the default "All" grouping.
                        if group != "All" {
                            Text(group)
                                .font(.headline)
                                .padding(.top, 4)
                        }
                        ForEach(ingredientsGroups[group] ?? [], id: \.self) { ingredient in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text(ingredient)
                                    .font(.body)
                            }
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                Text("Cooking Instructions 👨‍🍳")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let instructionsGroups = recipe.instructions {
                    ForEach(Array(instructionsGroups.keys.sorted()), id: \.self) { group in
                        // Optionally show the group header if the group is not "All"
                        if group != "All" {
                            Text(group)
                                .font(.headline)
                                .padding(.top, 4)
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
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
}
