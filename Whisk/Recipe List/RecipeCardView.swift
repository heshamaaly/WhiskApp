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
                
                ForEach(recipe.ingredients, id: \.self) { ingredient in
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(recipe.instructions, id: \.self) { instruction in
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
    }
}
