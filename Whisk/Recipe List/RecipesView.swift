//
//  RecipesView.swift
//  Whisk
//
//  Created by Hesham Aly on 3/28/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RecipesView: View {
    @State private var recipes: [Recipe] = []
    @State private var isLoading = true

    // Define the desired order for groups
    private let groupOrder = ["Today","Yesterday", "In The Last Week", "In The Last Month", "In The Last Year"]

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Recipes...")
                } else if recipes.isEmpty {
                    Text("No recipes found. Generate some!")
                } else {
                    // Group recipes by time category using native SwiftUI grouping.
                    let groupedRecipes = Dictionary(grouping: recipes) { recipe in
                        timeGroup(for: recipe.timestamp)
                    }

                    List {
                        ForEach(groupOrder, id: \.self) { groupName in
                            if let groupRecipes = groupedRecipes[groupName], !groupRecipes.isEmpty {
                                Section(header: Text(groupName)) {
                                    ForEach(groupRecipes) { recipe in
                                        // Wrap row content in a ZStack and overlay a hidden NavigationLink to hide the disclosure arrow.
                                        ZStack {
                                            rowContent(recipe)
                                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                                EmptyView()
                                            }
                                            .opacity(0)
                                        }
                                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                            if recipe.isFavorite {
                                                Button {
                                                    toggleFavorite(recipe)
                                                    hapticFeedback()
                                                } label: {
                                                    Label("Unfavorite", systemImage: "star.slash")
                                                }
                                                .tint(.gray)
                                            } else {
                                                Button {
                                                    toggleFavorite(recipe)
                                                    hapticFeedback()
                                                } label: {
                                                    Label("Favorite", systemImage: "star")
                                                }
                                                .tint(.yellow)
                                            }
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                deleteRecipe(recipe)
                                                hapticFeedback()
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .refreshable {
                        fetchRecipes()
                    }
                }
            }
            .navigationTitle("My Recipes")
            .onAppear {
                fetchRecipes()
            }
        }
    }

    // MARK: - Time Grouping Logic
    // MARK: - Time Grouping Logic
    private func timeGroup(for timestamp: Timestamp?) -> String {
        // Convert the Timestamp to a Date; if nil, use the current date.
        let date = timestamp?.dateValue() ?? Date()
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfDate = calendar.startOfDay(for: date)
        let diff = calendar.dateComponents([.day], from: startOfDate, to: startOfToday).day ?? 0
        
        if diff == 0 {
            return "Today"
        } else if diff == 1 {
            return "Yesterday"
        } else if diff < 7 {
            return "In The Last Week"
        } else if diff < 30 {
            return "In The Last Month"
        } else {
            return "In The Last Year"
        }
    }

    // MARK: - Row Content
    private func rowContent(_ recipe: Recipe) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                Text(recipe.text.replacingOccurrences(of: "Description:\n", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            Spacer()
            if recipe.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .contentShape(Rectangle())
    }

    // MARK: - Fetching Recipes
    private func fetchRecipes() {
        guard let user = Auth.auth().currentUser else { return }

        Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .collection("recipes")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching recipes: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }

                do {
                    self.recipes = try documents.compactMap { doc in
                        try doc.data(as: Recipe.self)
                    }
                } catch {
                    print("Error decoding recipes: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
    }

    // MARK: - Toggle Favorite
    private func toggleFavorite(_ recipe: Recipe) {
        guard let user = Auth.auth().currentUser,
              let docId = recipe.id else { return }

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

    // MARK: - Delete Recipe
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

    // MARK: - Haptic Feedback
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct RecipesView_Previews: PreviewProvider {
    static var previews: some View {
        RecipesView()
    }
}
