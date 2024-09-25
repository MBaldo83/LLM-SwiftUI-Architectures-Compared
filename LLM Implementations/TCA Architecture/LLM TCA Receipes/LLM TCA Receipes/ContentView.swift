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
struct RecipeListFeature: Reducer {
    struct State: Equatable {
        var recipes: IdentifiedArrayOf<Recipe>
        @PresentationState var selectedRecipe: RecipeDetailFeature.State?
    }
    
    enum Action: Equatable {
        case recipeTapped(Recipe)
        case recipeDetail(PresentationAction<RecipeDetailFeature.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .recipeTapped(recipe):
                state.selectedRecipe = RecipeDetailFeature.State(recipe: recipe)
                return .none
            case .recipeDetail:
                return .none
            }
        }
        .ifLet(\.$selectedRecipe, action: /Action.recipeDetail) {
            RecipeDetailFeature()
        }
    }
}

// RecipeDetail feature
struct RecipeDetailFeature: Reducer {
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
    let store: StoreOf<RecipeListFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.recipes) { recipe in
                    Button(action: { viewStore.send(.recipeTapped(recipe)) }) {
                        Text(recipe.name)
                    }
                }
            }
            .navigationTitle("Recipes")
            .sheet(
                store: self.store.scope(
                    state: \.$selectedRecipe,
                    action: { .recipeDetail($0) }
                )
            ) { store in
                RecipeDetailView(store: store)
            }
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
struct ContentView: View {
    let store: StoreOf<RecipeListFeature>
    
    var body: some View {
        NavigationView {
            RecipeListView(store: store)
        }
    }
}

