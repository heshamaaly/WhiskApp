//
//  HomeView.swift
//  Whisk
//
//  Created by Hesham Aly on 3/27/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    // Single input for describing the meal
    @State private var userInput = ""
    @State private var generatedRecipe = ""
    @State private var isLoading = false
    @State private var showAccountSheet = false
    @Namespace private var animation
    @State private var isRecipeGenerated = false

    // Structured recipe components
    @State private var recipeTitle: String = ""
    @State private var recipeDescription: String = ""
    @State private var recipeIngredients: [String] = []
    @State private var recipeInstructions: [String] = []

    private var openAIAPIKey: String {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let key = plist["OpenAI_API_Key"] as? String else {
            fatalError("Couldn't find API key in Secrets.plist")
        }
        return key
    }

    var body: some View {
        NavigationView {
            VStack {
                if !isRecipeGenerated {
                    // INITIAL STATE: Show large logo and centered text field.
                    VStack(spacing: 20) {
                        // Large logo (from your LogoHeaderView)
                        LogoHeaderView()
                            .matchedGeometryEffect(id: "logo", in: animation)
                        
                        // Expandable input view for user text input.
                        ExpandableInputView(text: $userInput) {
                            generateRecipe()
                        }
                        .matchedGeometryEffect(id: "textBox", in: animation)
                        
                        // Optionally, show a progress indicator if a generation is in progress.
                        if isLoading {
                            ProgressView("Whipping Up your Recipe...")
                                .padding()
                        }
                        
                        if generatedRecipe != "" {
                            ProgressView("Generating Recipe...")
                                .padding()
                        }
                        
                        Spacer()
                    }
                } else {
                    // FINAL STATE: Show FinalStateView with the generated recipe.
                    FinalStateView(
                        userInput: $userInput,
                        recipeTitle: recipeTitle,
                        recipeDescription: recipeDescription,
                        recipeIngredients: recipeIngredients,
                        recipeInstructions: recipeInstructions,
                        animation: animation,
                        onRegenerate: { generateRecipe() },
                        isLoading: isLoading
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAccountSheet = true }) {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
            .sheet(isPresented: $showAccountSheet) {
                AccountView()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isRecipeGenerated)
    }
    
    private func generateRecipe() {
        // Dismiss the keyboard.
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            
            // Ensure userInput is not empty.
            guard !userInput.isEmpty else {
                generatedRecipe = "Please describe your meal."
                return
            }
            
            // Reset the previous recipe data to clear the UI.
            recipeTitle = ""
            recipeDescription = ""
            recipeIngredients = []
            recipeInstructions = []
            generatedRecipe = ""
            
            // Show loading indicator.
            isLoading = true
        
        // Set up your OpenAI API key and request
        let apiKey = openAIAPIKey
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Prompt instructing the model to return valid JSON with four keys
        let prompt = """
        Generate a recipe based on the following description: "\(userInput)".
        Return your answer as valid JSON with exactly these keys:
          "title": a concise recipe name (include an emoji at the end to represent the recipe),
          "description": a short description of the dish,
          "ingredients": an array of strings (each string is an ingredient),
          "instructions": an array of strings (each string is a cooking step).
        Do not include any extra text, markdown formatting, or code fences.
        """
        
        let body: [String: Any] = [
            "model": "gpt-4o", // Change this if you have access to a different model.
            "messages": [
                ["role": "system", "content": "You are a helpful recipe generator named Whisk."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 800
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            DispatchQueue.main.async {
                self.generatedRecipe = "Error creating JSON body: \(error.localizedDescription)"
                self.isLoading = false
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.generatedRecipe = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.generatedRecipe = "No data received."
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                print("Full JSON Response: \(json)")
                
                if let errorDict = json["error"] as? [String: Any],
                   let errorMsg = errorDict["message"] as? String {
                    DispatchQueue.main.async {
                        self.generatedRecipe = "Error from OpenAI: \(errorMsg)"
                    }
                    return
                }
                
                if let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    print("Raw content from API:\n\(content)")
                    
                    // Remove any code fences
                    let cleanedContent: String
                    if let jsonStartIndex = content.firstIndex(of: "{") {
                        cleanedContent = String(content[jsonStartIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
                    } else {
                        cleanedContent = content
                    }
                    
                    if let responseData = cleanedContent.data(using: .utf8),
                       let result = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                       let title = result["title"] as? String,
                       let description = result["description"] as? String,
                       let ingredients = result["ingredients"] as? [String],
                       let instructions = result["instructions"] as? [String] {
                        
                        DispatchQueue.main.async {
                            self.recipeTitle = title
                            self.recipeDescription = description
                            self.recipeIngredients = ingredients
                            self.recipeInstructions = instructions
                            self.isRecipeGenerated = true //Triggers the transition to the final layout
                            
                            let combinedText = """
                            Description:
                            \(description)
                            
                            Ingredients:
                            \(ingredients.joined(separator: "\n"))
                            
                            Cooking Instructions:
                            \(instructions.joined(separator: "\n"))
                            """
                            
                            self.saveRecipeToFirestore(recipeText: combinedText, title: title)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.generatedRecipe = "Error parsing JSON structure from response."
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.generatedRecipe = "Invalid response format."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.generatedRecipe = "Error parsing response: \(error.localizedDescription)"
                }
            }
        }
        .resume()
    }
    
    private func saveRecipeToFirestore(recipeText: String, title: String) {
        guard let user = Auth.auth().currentUser else { return }
        let recipe = Recipe(
            recipeId: nil,
            title: title,
            text: recipeText,
            ingredients: self.userInput,
            mealType: "",
            timestamp: Date(),
            isFavorite: false
        )
        do {
            let _ = try Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .collection("recipes")
                .addDocument(from: recipe)
        } catch {
            print("Error saving recipe: \(error.localizedDescription)")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
