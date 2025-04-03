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
    var text: String
    var ingredients: [String]
    var instructions: [String]
    var mealType: String
    @ServerTimestamp var timestamp: Timestamp?
    var isFavorite: Bool
}
