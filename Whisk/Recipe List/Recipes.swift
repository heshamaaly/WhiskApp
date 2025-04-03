//
//  Recipes.swift
//  Whisk
//
//  Created by Hesham Aly on 3/28/25.
//

import Foundation
import FirebaseFirestore

struct Recipe: Codable, Identifiable {
    @DocumentID var id: String?      // Firestore will store this doc ID
    var recipeId: String?           // Optional custom ID if needed
    var title: String
    var text: String
    var ingredients: String
    var mealType: String
    var timestamp: Date
    var isFavorite: Bool
}
