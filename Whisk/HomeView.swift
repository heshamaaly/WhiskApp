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
    //FocusState Variable
    @FocusState private var isInputFocused: Bool
    
    // Single input for describing the meal
    @State private var userInput = ""
    @State private var generatedRecipe = ""
    @State private var isLoading = false
    @State private var showAccountSheet = false
    @Namespace private var animation
    @State private var isRecipeGenerated = false
    
    //Oredering for Groups in Recipes
    @State private var instructionsOrder: [String] = []
    @State private var ingredientsOrder: [String] = []
    @State private var tipsOrder: [String] = []
    
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
                        Spacer()
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
                        
                        //Spacer()
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            isInputFocused = true
                        }
                    }
                    
                } else {
                    FinalStateView(
                        userInput: $userInput,
                        recipes: multiRecipes,
                        selectedRecipeIndex: $selectedRecipeIndex,
                        animation: animation,
                        onRegenerate: { generateRecipe() },
                        isLoading: isLoading,
                        isRecipeGenerated: $isRecipeGenerated
                    )
                }
                }
            
            //Toolbar for empty state
                .toolbar {
                        if !isRecipeGenerated {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: { showAccountSheet = true }) {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(Color.black)
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showAccountSheet) {
                        AccountView()
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
        
        The recipe should use clear, simple instructions with minimal fluff.
        
        Format the recipe so that it is easy to read and enjoyable to cook from. Please follow these guidelines for each section:
                • Title: A clear, enticing title with an appropriate emoji
                • Description: A quick one-liner describing the dish (flavor, ease, nutrition, or vibe
                • Total Time: Specify the total time in minutes to prepare and cook (e.g., "30 minutes").
                • Servings: Indicate the number of people it serves (e.g., "2", "4").
                • Ingredients: Break them down logically and use everyday measurements (cups, tbsp, etc). Keep it concise but clear—enough detail to cook confidently. If it makes sense to group ingredients (for example, under headings like "Sauce", "Protein", "Bowl components"), then return ingredients as a JSON object where the keys are the group names and the values are arrays of ingredient strings. If grouping isn’t needed, simply return an array of ingredient strings.
                • Instructions: Make them step by step and have 3–5 main steps, each with its own clear heading or keyword. Use verbs to lead: Cook, Mix, Add, Drizzle. Tips and alternatives embedded casually. Similarly, if the instructions naturally break into sections (with clear headings or keywords), return them as a JSON object with keys as section names and values as arrays of step strings; otherwise, return a simple array of steps.
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
        If the query is open-ended and not for a specific dish (e.g., "high protein dinner", or "high protein dinner with salmon", or "gluten free pasta"), return up to 3 recipe ideas as a JSON object with a key "recipes" whose value is an array of such recipe objects.
        
        Do not include any extra text, markdown formatting, or code fences.
        """
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You are a helpful recipe generator named Whisk."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.5,
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
                    
                    // Remove any code fences and get cleanedContent
                    let cleanedContent: String
                    if let jsonStartIndex = content.firstIndex(of: "{") {
                        cleanedContent = String(content[jsonStartIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)
                    } else {
                        cleanedContent = content
                    }
                    
                    // --- NEW CODE: Extract raw recipe substrings ---
                    var rawRecipeSubstrings: [String] = []
                    let recipePattern = "\"recipes\"\\s*:\\s*\\[(.*?)\\]\\s*\\}"
                    if let regex = try? NSRegularExpression(pattern: recipePattern, options: [.dotMatchesLineSeparators]),
                       let match = regex.firstMatch(in: cleanedContent, options: [], range: NSRange(location: 0, length: (cleanedContent as NSString).length)) {
                        
                        // Extract the content inside the recipes array
                        let recipesArrayString = (cleanedContent as NSString).substring(with: match.range(at: 1))
                        
                        // Use another regex to find each individual recipe object.
                        let individualPattern = "\\{\\s*\"title\""
                        if let recipeRegex = try? NSRegularExpression(pattern: individualPattern, options: []) {
                            let nsRecipesString = recipesArrayString as NSString
                            let recipeMatches = recipeRegex.matches(in: recipesArrayString, options: [], range: NSRange(location: 0, length: nsRecipesString.length))
                            for (index, recipeMatch) in recipeMatches.enumerated() {
                                let start = recipeMatch.range.location
                                let end = (index < recipeMatches.count - 1) ? recipeMatches[index + 1].range.location : nsRecipesString.length
                                let range = NSRange(location: start, length: end - start)
                                let recipeSubstring = nsRecipesString.substring(with: range)
                                rawRecipeSubstrings.append(recipeSubstring)
                            }
                            print("Extracted \(rawRecipeSubstrings.count) raw recipe substrings.")
                        }
                    }
                    
                    
                    //Convert Cleaned content to data
                    if let responseData = cleanedContent.data(using: .utf8) {
                        do {
                            // MULTI RECIPE PARSING
                            if let multiRecipeResult = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                               let recipesArray = multiRecipeResult["recipes"] as? [[String: Any]], !recipesArray.isEmpty {
                                
                                var parsedRecipes: [Recipe] = []
                                
                                // Enumerate over recipes so we can use the index if needed.
                                for (index, recipeDict) in recipesArray.enumerated() {
                                    // Extract mandatory fields.
                                    guard let title = recipeDict["title"] as? String,
                                          let description = recipeDict["description"] as? String else {
                                        continue
                                    }
                                    
                                    // Optional keys.
                                    let totalTime = recipeDict["totalTime"] as? String
                                    let servings = recipeDict["servings"] as? String
                                    
                                    // --- Use the helper to extract this recipe's JSON substring ---
                                    let recipeJsonSubstring: String
                                    if let extractedSubstring = extractRecipeSubstring(forTitle: title, from: cleanedContent) {
                                        recipeJsonSubstring = extractedSubstring
                                        print("Extracted raw JSON substring for recipe '\(title)'.")
                                    } else if let fallbackData = try? JSONSerialization.data(withJSONObject: recipeDict, options: []),
                                              let fallbackString = String(data: fallbackData, encoding: .utf8) {
                                        recipeJsonSubstring = fallbackString
                                        print("Fallback: Reserialized JSON for recipe '\(title)'.")
                                    } else {
                                        recipeJsonSubstring = ""
                                        print("Failed to obtain raw JSON substring for recipe '\(title)'.")
                                    }
                                    
                                    // --- Parse Ingredients ---
                                    var ingredientsParsed: [String: [String]]? = nil
                                    var ingredientsOrderForThisRecipe: [String] = []
                                    if let ingredientsDict = recipeDict["ingredients"] as? [String: [String]] {
                                        ingredientsParsed = ingredientsDict
                                        if let order = extractOrderedKeys(for: "ingredients", from: recipeJsonSubstring) {
                                            ingredientsOrderForThisRecipe = order
                                            print("Extracted ingredients order for '\(title)': \(order)")
                                        } else {
                                            ingredientsOrderForThisRecipe = Array(ingredientsDict.keys)
                                            print("Fallback ingredients order for '\(title)': \(Array(ingredientsDict.keys))")
                                        }
                                    } else if let ingredientsArray = recipeDict["ingredients"] as? [String] {
                                        ingredientsParsed = ["All": ingredientsArray]
                                        ingredientsOrderForThisRecipe = ["All"]
                                        print("Recipe '\(title)' ingredients as flat array, order set to: All")
                                    }
                                    
                                    // --- Parse Instructions ---
                                    var instructionsParsed: [String: [String]]? = nil
                                    var instructionsOrderForThisRecipe: [String] = []
                                    if let instructionsDict = recipeDict["instructions"] as? [String: [String]] {
                                        instructionsParsed = instructionsDict
                                        if let order = extractOrderedKeys(for: "instructions", from: recipeJsonSubstring) {
                                            instructionsOrderForThisRecipe = order
                                            print("Extracted instructions order for '\(title)': \(order)")
                                        } else {
                                            instructionsOrderForThisRecipe = Array(instructionsDict.keys)
                                            print("Fallback instructions order for '\(title)': \(Array(instructionsDict.keys))")
                                        }
                                    } else if let instructionsArray = recipeDict["instructions"] as? [String] {
                                        instructionsParsed = ["All": instructionsArray]
                                        instructionsOrderForThisRecipe = ["All"]
                                        print("Recipe '\(title)' instructions as flat array, order set to: All")
                                    }
                                    
                                    // --- Parse Tips ---
                                    var tipsParsed: [String: [String]]? = nil
                                    var tipsOrderForThisRecipe: [String] = []
                                    if let tipsValue = recipeDict["tips"] {
                                        if let tipsDict = tipsValue as? [String: [String]] {
                                            tipsParsed = tipsDict
                                            if let order = extractOrderedKeys(for: "tips", from: recipeJsonSubstring) {
                                                tipsOrderForThisRecipe = order
                                                print("Extracted tips order for '\(title)': \(order)")
                                            } else {
                                                tipsOrderForThisRecipe = Array(tipsDict.keys)
                                                print("Fallback tips order for '\(title)': \(Array(tipsDict.keys))")
                                            }
                                        } else if let tipsArray = tipsValue as? [String] {
                                            tipsParsed = ["All": tipsArray]
                                            tipsOrderForThisRecipe = ["All"]
                                            print("Recipe '\(title)' tips as flat array, order set to: All")
                                        }
                                    }
                                    
                                    // Create the Recipe object with the extracted ordering.
                                    let recipe = Recipe(
                                        recipeId: nil,
                                        title: title,
                                        text: description,
                                        totalTime: totalTime,
                                        servings: servings,
                                        ingredients: ingredientsParsed,
                                        instructions: instructionsParsed,
                                        tips: tipsParsed,
                                        // Pass the per-recipe ordering arrays we extracted earlier.
                                        instructionsOrder: instructionsOrderForThisRecipe,
                                        ingredientsOrder: ingredientsOrderForThisRecipe,
                                        tipsOrder: tipsOrderForThisRecipe,
                                        mealType: "",
                                        timestamp: nil,
                                        isFavorite: false
                                    )
                                    parsedRecipes.append(recipe)
                                }
                                
                                DispatchQueue.main.async {
                                    self.multiRecipes = parsedRecipes
                                    self.selectedRecipeIndex = 0
                                    self.isRecipeGenerated = true
                                    
                                    // Save each recipe to Firestore.
                                    for recipe in parsedRecipes {
                                        self.saveRecipeToFirestore(recipe: recipe)
                                    }
                                }
                            }
                            else if let singleRecipeResult = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                                // Fallback: single recipe parsing.
                                if let title = singleRecipeResult["title"] as? String,
                                   let description = singleRecipeResult["description"] as? String,
                                   let ingredientsValue = singleRecipeResult["ingredients"],
                                   let instructionsValue = singleRecipeResult["instructions"] {
                                    
                                    // Parse ingredients: either dictionary or array.
                                    var ingredientsParsed: [String: [String]]? = nil
                                    if let ingredientsDict = singleRecipeResult["ingredients"] as? [String: [String]] {
                                        ingredientsParsed = ingredientsDict
                                        if let order = extractOrderedKeys(for: "ingredients", from: cleanedContent) {
                                            ingredientsOrder = order
                                        } else {
                                            ingredientsOrder = Array(ingredientsDict.keys)
                                        }
                                    } else if let ingredientsArray = singleRecipeResult["ingredients"] as? [String] {
                                        ingredientsParsed = ["All": ingredientsArray]
                                        ingredientsOrder = ["All"]
                                    }
                                    
                                    // Parse instructions.
                                    var instructionsParsed: [String: [String]]? = nil
                                    if let instructionsDict = singleRecipeResult["instructions"] as? [String: [String]] {
                                        instructionsParsed = instructionsDict
                                        if let order = extractOrderedKeys(for: "instructions", from: cleanedContent) {
                                            instructionsOrder = order
                                        } else {
                                            instructionsOrder = Array(instructionsDict.keys)
                                        }
                                    } else if let instructionsArray = singleRecipeResult["instructions"] as? [String] {
                                        instructionsParsed = ["All": instructionsArray]
                                        instructionsOrder = ["All"]
                                    }
                                    
                                    // Parse optional totalTime, servings.
                                    let totalTime = singleRecipeResult["totalTime"] as? String
                                    let servings = singleRecipeResult["servings"] as? String
                                   
                                    //Parse Tips
                                    var tipsParsed: [String: [String]]? = nil
                                    if let tipsDict = singleRecipeResult["tips"] as? [String: [String]] {
                                        tipsParsed = tipsDict
                                        if let order = extractOrderedKeys(for: "tips", from: cleanedContent) {
                                            tipsOrder = order
                                        } else {
                                            tipsOrder = Array(tipsDict.keys)
                                        }
                                    } else if let tipsArray = singleRecipeResult["tips"] as? [String] {
                                        tipsParsed = ["All": tipsArray]
                                        tipsOrder = ["All"]
                                    }
                                    
                                    let singleRecipe = Recipe(
                                        recipeId: nil,
                                        title: title,
                                        text: description,
                                        totalTime: totalTime,
                                        servings: servings,
                                        ingredients: ingredientsParsed,
                                        instructions: instructionsParsed,
                                        tips: tipsParsed,
                                        instructionsOrder: instructionsOrder,
                                        ingredientsOrder: ingredientsOrder,
                                        tipsOrder: tipsOrder,
                                        mealType: "",
                                        timestamp: nil,
                                        isFavorite: false
                                    )
                                    DispatchQueue.main.async {
                                        self.recipeTitle = title
                                        self.recipeDescription = description
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
    
    
    // Helper function to extract the JSON substring for a recipe based on its title.
    // This function attempts to find the object corresponding to the recipe with the given title.
    func extractRecipeSubstring(forTitle title: String, from fullJson: String) -> String? {
        // Build a regex pattern that matches a JSON object containing "title": "<title>".
        // This pattern uses a non-greedy capture for the content after the title until the closing brace.
        let escapedTitle = NSRegularExpression.escapedPattern(for: title)
        let pattern = "\\{\\s*\"title\"\\s*:\\s*\"\(escapedTitle)\"(.*?)\\}(?=\\s*,\\s*\\{|\\s*\\])"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else { return nil }
        let nsString = fullJson as NSString
        if let match = regex.firstMatch(in: fullJson, options: [], range: NSRange(location: 0, length: nsString.length)) {
            let recipeSubstring = nsString.substring(with: match.range)
            return recipeSubstring
        }
        return nil
    }
    
    //Capture ordering of groupings in the JSON file from API
    func extractOrderedKeys(for field: String, from jsonString: String) -> [String]? {
        // This regex captures the content of the field's JSON object.
        let pattern = "\"\(field)\"\\s*:\\s*\\{([^\\}]+)\\}"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        
        let nsString = jsonString as NSString
        guard let match = regex.firstMatch(in: jsonString, options: [], range: NSRange(location: 0, length: nsString.length)) else { return nil }
        
        let keysBlock = nsString.substring(with: match.range(at: 1))
        
        // Now extract keys from the keysBlock using another regex.
        let keyPattern = "\"([^\"]+)\"\\s*:"
        guard let keyRegex = try? NSRegularExpression(pattern: keyPattern, options: []) else { return nil }
        let keyMatches = keyRegex.matches(in: keysBlock, options: [], range: NSRange(location: 0, length: (keysBlock as NSString).length))
        let keys = keyMatches.compactMap { (keysBlock as NSString).substring(with: $0.range(at: 1)) }
        return keys
    }
    
    //Save Recipe Function
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

//Preview
        struct HomeView_Previews: PreviewProvider {
            static var previews: some View {
                HomeView()
            }
        }
