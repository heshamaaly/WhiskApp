//
//  RecipeSnapshotView.swift
//  Whisk
//
//  Created by Hesham Aly on 4/16/25.
//
import SwiftUI

struct RecipeSnapshotView: View {
  
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
        VStack(spacing: 16) {
            // 1) Title Section
            HStack(alignment: .top) {
                Text(recipe.title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                    .padding(.leading, 30)
                
                Spacer()
                Image(systemName: recipe.isFavorite ? "star.fill" : "star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(recipe.isFavorite ? .yellow : .brandGray)
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
            
            
        }
        .padding(.top, 8)
    }
}
