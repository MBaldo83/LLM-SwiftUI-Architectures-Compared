//
//  ContentView.swift
//  LLM TCA Receipes
//
//  Created by Michael Baldock on 25/09/2024.
//

import SwiftUI
import ComposableArchitecture

struct Recipe: Equatable, Identifiable {
    
    // Recipe model
    enum ThumbSelection: Equatable {
        case thumbsUp
        case thumbsDown
    }
    
    let id: UUID
    var name: String
    var ingredients: [String]
    var instructions: String
    var relatedRecipeIDs: [UUID]
    var thumbSelection: ThumbSelection?
    
    func updating(name: String? = nil, ingredients: [String]? = nil, instructions: String? = nil, relatedRecipeIDs: [UUID]? = nil, thumbSelection: ThumbSelection? = nil) -> Recipe {
        Recipe(
            id: self.id,
            name: name ?? self.name,
            ingredients: ingredients ?? self.ingredients,
            instructions: instructions ?? self.instructions,
            relatedRecipeIDs: relatedRecipeIDs ?? self.relatedRecipeIDs,
            thumbSelection: thumbSelection ?? self.thumbSelection
        )
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.ingredients == rhs.ingredients &&
        lhs.instructions == rhs.instructions &&
        lhs.relatedRecipeIDs == rhs.relatedRecipeIDs &&
        lhs.thumbSelection == rhs.thumbSelection
    }
}

// RecipeList feature
@Reducer
struct RecipeListFeature {
    @ObservableState
    struct State: Equatable {
        var recipes: IdentifiedArrayOf<Recipe>
        var path = StackState<RecipeDetailFeature.State>()
    }
    
    enum Action: Equatable {
        case path(StackAction<RecipeDetailFeature.State, RecipeDetailFeature.Action>)
        case updateRecipe(Recipe)
        case updateRecipeThumbSelection(id: Recipe.ID, selection: Recipe.ThumbSelection?)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case let .path(.element(id: _, action: .updateThumbSelection(newSelection))):
                if let recipeID = state.path.last?.recipe.id,
                   let index = state.recipes.index(id: recipeID) {
                    state.recipes[index].thumbSelection = newSelection
                }
                return .none
            
            case let .updateRecipe(recipe):
                if let index = state.recipes.index(id: recipe.id) {
                    state.recipes[index] = recipe
                }
                return .none
                
            case let .updateRecipeThumbSelection(id, selection):
                if let index = state.recipes.index(id: id) {
                    state.recipes[index].thumbSelection = selection
                }
                return .none
                
            case .path:
                return .none
                
            }
        }
        .forEach(\.path, action: \.path) {
            RecipeDetailFeature()
        }
    }
}

// RecipeDetail feature
@Reducer
struct RecipeDetailFeature {
    @ObservableState
    struct State: Equatable {
        var recipe: Recipe
    }
    
    enum Action: Equatable {
        case updateRecipe(Recipe)
        case updateThumbSelection(Recipe.ThumbSelection?)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .updateRecipe(updatedRecipe):
                state.recipe = updatedRecipe
                return .none
            case let .updateThumbSelection(newSelection):
                state.recipe.thumbSelection = newSelection
                return .none
            }
        }
    }
}

// RecipeList view
struct RecipeListView: View {
    @Bindable var store: StoreOf<RecipeListFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                ForEach(store.recipes) { recipe in
                    HStack {
                        NavigationLink(state: RecipeDetailFeature.State(recipe: recipe)) {
                            Text(recipe.name)
                        }
                        Spacer()
                        MultiThumbSelectionView(
                            selectedThumb: Binding(
                                get: { recipe.thumbSelection },
                                set: { newValue in
                                    store.send(.updateRecipeThumbSelection(id: recipe.id, selection: newValue))
                                }
                            )
                        )
                    }
                }
            }
            .navigationTitle("Recipes")
        } destination: { store in
            RecipeDetailView(store: store)
        }
    }
}

// RecipeDetail view
struct RecipeDetailView: View {
    let store: StoreOf<RecipeDetailFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                Text(viewStore.recipe.name)
                    .font(.title)
                
                MultiThumbSelectionView(
                    selectedThumb: viewStore.binding(
                        get: \.recipe.thumbSelection,
                        send: { RecipeDetailFeature.Action.updateThumbSelection($0) }
                    )
                )
                
                Text("Ingredients:")
                    .font(.headline)
                ForEach(viewStore.recipe.ingredients, id: \.self) { ingredient in
                    Text("• \(ingredient)")
                }
                
                Text("Instructions:")
                    .font(.headline)
                Text(viewStore.recipe.instructions)
            }
            .padding()
        }
    }
}

// Root view

@main
struct RecipesApp: App {
    let store: StoreOf<RecipeListFeature> = Store(
        initialState: RecipeListFeature.State(
            recipes: [
                Recipe(
                    id: UUID(),
                    name: "Pasta Carbonara",
                    ingredients: ["Spaghetti", "Eggs", "Pancetta", "Parmesan"],
                    instructions: "Cook pasta...",
                    relatedRecipeIDs: []
                ),
                Recipe(
                    id: UUID(),
                    name: "Chicken Curry",
                    ingredients: ["Chicken", "Curry Powder", "Coconut Milk"],
                    instructions: "Sauté chicken...",
                    relatedRecipeIDs: []
                ),
                Recipe(
                    id: UUID(),
                    name: "Spaghetti Bolognese",
                    ingredients: ["Spaghetti", "Ground Beef", "Tomato Sauce", "Onions"],
                    instructions: "Brown the beef...",
                    relatedRecipeIDs: []
                )
            ]
        )
    ) {
        RecipeListFeature()
    }
    
    init() {
        // Add related recipes
        let recipes = store.withState { $0.recipes }
        let carbonara = recipes[0]
        let curry = recipes[1]
        let bolognese = recipes[2]
        
        store.send(.updateRecipe(carbonara.updating(relatedRecipeIDs: [bolognese.id])))
        store.send(.updateRecipe(bolognese.updating(relatedRecipeIDs: [carbonara.id])))
    }
    
    var body: some Scene {
        WindowGroup {
            RecipeListView(store: store)
        }
    }
}
