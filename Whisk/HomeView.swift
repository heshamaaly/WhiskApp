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
    
    // Structured recipe components for single recipe fallback (if needed)
    @State private var recipeTitle: String = ""
    @State private var recipeDescription: String = ""
    @State private var recipeIngredients: [String] = []
    @State private var recipeInstructions: [String] = []
    
    // Multiple recipes support
    @State private var multiRecipes: [Recipe] = []
    @State private var selectedRecipeIndex: Int = 0
    
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
                        // Large logo from LogoHeaderView
                        LogoHeaderView()
                            .matchedGeometryEffect(id: "logo", in: animation)
                        
                        // Expandable input view for user text input.
                        ExpandableInputView(text: $userInput) {
                            generateRecipe()
                        }
                        .matchedGeometryEffect(id: "textBox", in: animation)
                        
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
                    //Toolbar for empty state
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { showAccountSheet = true }) {
                                Image(systemName: "person.fill") //Made this a square for testing!!
                                    //.symbolEffect(.appear)
                                    .foregroundStyle(Color.black)
                            }
                        }
                    }
                    .sheet(isPresented: $showAccountSheet) {
                        AccountView()
                    }
                    
                } else {
                    FinalStateView(
                        userInput: $userInput,
                        recipes: multiRecipes,
                        selectedRecipeIndex: $selectedRecipeIndex,
                        animation: animation,
                        onRegenerate: { generateRecipe() },
                        isLoading: isLoading
                    )
                }
            }
            
        }
        .animation(.easeInOut(duration: 0.5), value: isRecipeGenerated)
    }
    
    func generateRecipe() {
        // Dismiss the keyboard.
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // Ensure userInput is not empty.
        guard !userInput.isEmpty else {
            generatedRecipe = "Please describe your meal."
            return
        }
        
        // Reset the previous recipe data.
        recipeTitle = ""
        recipeDescription = ""
        recipeIngredients = []
        recipeInstructions = []
        generatedRecipe = ""
        
        isLoading = true
        
        let apiKey = openAIAPIKey
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let prompt = """
        Generate a well-structured, easy-to-follow recipe that feels approachable and modern based on the following description: "\(userInput)".

        The recipe should:
        • Appeal to someone who wants yummy, healthy meals without being overly complex.
        • Use clear, simple instructions with minimal fluff.
        
        Format the recipe so that it is easy to read and enjoyable to cook from. Please follow these guidelines for each section:
                • Title: A clear, enticing title with an appropriate emoji
                • Description: A quick one-liner describing the dish (flavor, ease, nutrition, or vibe
                • Total Time: Specify the total time in minutes to prepare and cook (e.g., "30 minutes").
                • Servings: Indicate the number of people it serves (e.g., "2", "4").
                • Ingredients: Break them down logically and use everyday measurements (cups, tbsp, etc). Keep it concise but clear—enough detail to cook confidently. If it makes sense to group ingredients (for example, under headings like "Sauce", "Protein", "Bowl components"), then return ingredients as a JSON object where the keys are the group names and the values are arrays of ingredient strings. If grouping isn’t needed, simply return an array of ingredient strings.
                • Instructions: Make them step by step and have 3–5 main steps, each with its own clear heading or keyword. Use verbs to lead: Cook, Mix, Add, Drizzle. Tips and alternatives embedded casually.  Similarly, if the instructions naturally break into sections (with clear headings or keywords), return them as a JSON object with keys as section names and values as arrays of step strings; otherwise, return a simple array of steps.
                • Total Time: Total time it takes to prepare and cook in minutes, e.g., '30 minutes'
                • Tips: Optionally, include tips or shortcuts. If there are multiple categories of tips, return them as a JSON object with keys as category names and values as arrays of tip strings; otherwise, return an array of tip strings. Callouts like: “Want it spicy?”, “Swap rice for cauliflower rice to keep it low-carb.”, “Add seaweed salad for a sushi bowl vibe.”

        Return the recipe in the following JSON structure:

        {
          "title": "[Recipe Title with emoji]",
          "description": "[Description]",
          "totalTime": "[Total time, e.g., '30 minutes']",
          "servings": "[Number of servings]",
          "ingredients": (either an array of strings or an object mapping group names to arrays of strings),
          "instructions": (either an array of strings or an object mapping section names to arrays of strings),
          "tips": (either an array of strings or an object mapping categories to arrays of strings)
        }

        If the query is specific (e.g., "steak salad"), return a single recipe JSON object with the above keys.
        If the query is open-ended (e.g., "give me ideas for a high protein dinner"), return a JSON object with a key "recipes" whose value is an array of such recipe objects.

        Do not include any extra text, markdown formatting, or code fences.
        """
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You are a helpful recipe generator named Whisk."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 1600
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
                    
                    if let responseData = cleanedContent.data(using: .utf8) {
                        do {
                            // Try to parse multiple recipes first.
                            if let multiRecipeResult = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                               let recipesArray = multiRecipeResult["recipes"] as? [[String: Any]], !recipesArray.isEmpty {
                                
                                var parsedRecipes: [Recipe] = []
                                for recipeDict in recipesArray {
                                    if let title = recipeDict["title"] as? String,
                                       let description = recipeDict["description"] as? String,
                                       let ingredientsArray = recipeDict["ingredients"] as? [String],
                                       let instructionsArray = recipeDict["instructions"] as? [String] {
                                        let recipe = Recipe(
                                            recipeId: nil,
                                            title: title,
                                            text: description,
                                            ingredients: ingredientsArray,  // Now an array of Strings
                                            instructions: instructionsArray, // Pass instructions array
                                            mealType: "",
                                            timestamp: nil, // Use real timestamp if available
                                            isFavorite: false
                                        )
                                        parsedRecipes.append(recipe)
                                    }
                                }
                                
                                DispatchQueue.main.async {
                                    self.multiRecipes = parsedRecipes
                                    self.selectedRecipeIndex = 0
                                    if let firstRecipe = parsedRecipes.first {
                                        self.recipeTitle = firstRecipe.title
                                        self.recipeDescription = firstRecipe.text
                                        self.recipeIngredients = firstRecipe.ingredients
                                        self.recipeInstructions = firstRecipe.instructions
                                    }
                                    self.isRecipeGenerated = true
                                    // Save each recipe independently to Firestore.
                                    for recipe in parsedRecipes {
                                        self.saveRecipeToFirestore(recipe: recipe)
                                    }
                                }
                            } else if let singleRecipeResult = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                                // Fallback: single recipe parsing.
                                if let title = singleRecipeResult["title"] as? String,
                                   let description = singleRecipeResult["description"] as? String,
                                   let ingredientsArray = singleRecipeResult["ingredients"] as? [String],
                                   let instructionsArray = singleRecipeResult["instructions"] as? [String] {
                                    let singleRecipe = Recipe(
                                        recipeId: nil,
                                        title: title,
                                        text: description,
                                        ingredients: ingredientsArray,
                                        instructions: instructionsArray,
                                        mealType: "",
                                        timestamp: nil,
                                        isFavorite: false
                                        
                                    )
                                    DispatchQueue.main.async {
                                        self.recipeTitle = title
                                        self.recipeDescription = description
                                        self.recipeIngredients = ingredientsArray
                                        self.recipeInstructions = instructionsArray
                                        self.multiRecipes = [singleRecipe]
                                        self.selectedRecipeIndex = 0
                                        self.isRecipeGenerated = true
                                        self.saveRecipeToFirestore(recipe: singleRecipe)
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        self.generatedRecipe = "Error parsing single recipe structure."
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.generatedRecipe = "Invalid response format."
                                }
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.generatedRecipe = "Error parsing JSON structure from response: \(error.localizedDescription)"
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.generatedRecipe = "Error parsing JSON: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func saveRecipeToFirestore(recipe: Recipe) {
        guard let user = Auth.auth().currentUser else { return }
        do {
            // Print the document ID (should be nil)
            print("Recipe id before saving: \(recipe.id ?? "nil")")
            
            // Print the timestamp (should be nil since we want Firestore to set it)
            if let timestamp = recipe.timestamp {
                print("Timestamp before saving: \(timestamp)")
            } else {
                print("Timestamp before saving: nil")
            }
            
            let _ = try Firestore.firestore()
                .collection("users")
                .document(user.uid)
                .collection("recipes")
                .addDocument(from: recipe)
            print("Successfully saved recipe: \(recipe.title)")
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
