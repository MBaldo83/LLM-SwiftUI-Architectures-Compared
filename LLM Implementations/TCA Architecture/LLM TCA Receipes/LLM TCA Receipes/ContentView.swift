//
//  ContentView.swift
//  LLM TCA Receipes
//
//  Created by Michael Baldock on 25/09/2024.
//

import SwiftUI
import ComposableArchitecture

// Recipe model
struct Recipe: Equatable, Identifiable {
    let id: UUID
    var name: String
    var ingredients: [String]
    var instructions: String
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
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
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
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .updateRecipe(updatedRecipe):
                state.recipe = updatedRecipe
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
                    NavigationLink(state: RecipeDetailFeature.State(recipe: recipe)) {
                        Text(recipe.name)
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
                Recipe(id: UUID(), name: "Pasta Carbonara", ingredients: ["Spaghetti", "Eggs", "Pancetta", "Parmesan"], instructions: "Cook pasta..."),
                Recipe(id: UUID(), name: "Chicken Curry", ingredients: ["Chicken", "Curry Powder", "Coconut Milk"], instructions: "Sauté chicken...")
                // Add more recipes as needed
            ]
        )
    ) {
        RecipeListFeature()
    }

    var body: some Scene {
        WindowGroup {
            RecipeListView(store: store)
        }
    }
}
