//___FILEHEADER___

import SwiftUI
import ComposableArchitecture

@main
struct RecipeRating: App {
    
    static let store = Store(initialState: RecipeListFeature.State(recipes: Shared(builtInRecipes))) {
        RecipeListFeature()._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            RecipeListView(store: RecipeRating.store)
        }
    }
}
