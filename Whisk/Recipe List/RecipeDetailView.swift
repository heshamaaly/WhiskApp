//
//  RecipeDetailView.swift
//  Whisk
//
//  Created by Hesham Aly on 3/29/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 1) Title Section
                Text(recipe.title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                
                // 2) Description Section
                Text(recipe.text)
                    .font(.body)
                    .foregroundColor(Color(red: 127/255, green: 127/255, blue: 127/255))
                    .padding(.horizontal)
                
                // 3) Ingredients & Instructions Section
                VStack(alignment: .leading, spacing: 16) {
                    // Ingredients
                    Text("Ingredients 📝")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text(ingredient)
                                    .font(.body)
                            }
                        }
                    }
                    
                    Divider()
                        .background(Color(white: 0.9))
                        .padding(.vertical, 4)
                    
                    // Instructions
                    Text("Cooking Instructions 👨‍🍳")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(recipe.instructions, id: \.self) { instruction in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text(instruction)
                                    .font(.body)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 8)
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
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
