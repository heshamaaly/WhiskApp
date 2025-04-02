//
//  FavoritesView.swift
//  Whisk
//
//  Created by Hesham Aly on 3/28/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FavoritesView: View {
    @State private var favoriteRecipes: [Recipe] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading Favorites...")
                } else if favoriteRecipes.isEmpty {
                    Text("No favorite recipes found.")
                } else {
                    List {
                        ForEach(favoriteRecipes) { recipe in
                            ZStack {
                                rowContent(recipe)
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        // For favorites, swiping from left-to-right will unfavorite.
                                        Button {
                                            toggleFavorite(recipe)
                                            hapticFeedback()
                                        } label: {
                                            Label("Unfavorite", systemImage: "star.slash")
                                        }
                                        .tint(.gray)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteRecipe(recipe)
                                            hapticFeedback()
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                
                                // Hidden NavigationLink to show RecipeDetailView when tapped.
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                            .padding(8)
                            .cornerRadius(8)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Favorites")
        }
        .onAppear {
            fetchFavoriteRecipes()
        }
    }
    
    private func rowContent(_ recipe: Recipe) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                Text(recipe.text
                        .replacingOccurrences(of: "Description:\n", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            Spacer()
            // Always show a star icon for favorited recipes.
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
        }
        .contentShape(Rectangle())
    }
    
    private func fetchFavoriteRecipes() {
        guard let user = Auth.auth().currentUser else { return }
        
        Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .collection("recipes")
            .whereField("isFavorite", isEqualTo: true)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching favorite recipes: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                do {
                    self.favoriteRecipes = try documents.compactMap { doc in
                        try doc.data(as: Recipe.self)
                    }
                } catch {
                    print("Error decoding favorite recipes: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
    }
    
    private func toggleFavorite(_ recipe: Recipe) {
        guard let user = Auth.auth().currentUser,
              let docId = recipe.id else { return }
        
        // If the recipe is currently favorited, remove it from the local array with animation
        if recipe.isFavorite {
            withAnimation {
                self.favoriteRecipes.removeAll { $0.id == recipe.id }
            }
        }
        
        let newFavoriteStatus = !recipe.isFavorite
        Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .collection("recipes")
            .document(docId)
            .updateData(["isFavorite": newFavoriteStatus]) { error in
                if let error = error {
                    print("Error updating favorite: \(error.localizedDescription)")
                }
            }
    }
    
    private func deleteRecipe(_ recipe: Recipe) {
        guard let user = Auth.auth().currentUser,
              let docId = recipe.id else { return }
        
        Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .collection("recipes")
            .document(docId)
            .delete { error in
                if let error = error {
                    print("Error deleting recipe: \(error.localizedDescription)")
                }
            }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
