//
//  Recipes.swift
//  Whisk
//
//  Created by Hesham Aly on 3/28/25.
//

import Foundation
import FirebaseFirestore

struct Recipe: Identifiable, Codable {
    @DocumentID var id: String?
    var recipeId: String?
    var title: String
    var text: String //Used for the description
    var totalTime: String?      // e.g., "30 minutes"
    var servings: String?       // e.g., "2" or "4"
    var ingredients: [String: [String]]?
    var instructions: [String: [String]]?
    var tips: [String: [String]]?
    var mealType: String
    @ServerTimestamp var timestamp: Timestamp?
    var isFavorite: Bool
}
