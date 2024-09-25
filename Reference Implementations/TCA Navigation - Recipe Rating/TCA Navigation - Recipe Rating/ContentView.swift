import SwiftUI
import ComposableArchitecture

struct RecipeListView: View {
    @Bindable var store: StoreOf<RecipeListFeature>
    
    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            List(store.state.recipes) { recipe in
                NavigationLink(
                    state: RecipeListFeature.Path.State.detailRecipe(
                        RecipeDetailFeature.State(recipes: store.state.$recipes, recipe: recipe)
                    )
                ) {
                    HStack {
                        MultiThumbSelectionView(
                            selectedThumb: Binding(get: {
                                recipe.selectedThumb
                            }, set: { [recipe] selection in
                                store.send(.thumbPressed(recipeId: recipe.id, selection: selection))
                            })
                        )
                        Text(recipe.name)
                    }
                    .padding()
                }
                .navigationTitle("Recipes")
            }
        } destination: { store in
            switch store.case {
            case .detailRecipe(let store):
                RecipeDetail(store: store)
            }
        }
    }
}

@Reducer
struct RecipeListFeature {
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        @Shared var recipes: [Recipe]
    }
    enum Action {
        case path(StackActionOf<Path>)
        case thumbPressed(recipeId: Recipe.ID, selection: Recipe.ThumbSelection?)
    }
    
    @Reducer
    enum Path {
        case detailRecipe(RecipeDetailFeature)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .thumbPressed(recipeId, selection):
                if let index = state.recipes.firstIndex(where: { $0.id == recipeId }) {
                    state.recipes[index].selectedThumb = selection
                }
                return .none
                
            case .path(.element(id: let id, action: .detailRecipe(.thumbPressed))):
                
                guard let recipeState = state.path[id: id],
                      case let .detailRecipe(detailFeature) = recipeState,
                      let index = state.recipes.firstIndex(where: { $0.id == detailFeature.recipe.id })
                else { return .none }
                
                state.recipes[index] = detailFeature.recipe
                return .none
                
            case .path(.element(id: _, action: .detailRecipe(.relatedRecipeSelected(let recipe)))):
                state.path.append(.detailRecipe(.init(recipes: state.$recipes, recipe: recipe)))
                return .none
                
            case .path:
                return .none
                
            }
        }
        .forEach(\.path, action: \.path)
    }
}

// Helpers for code example
struct RecipeDetail: View {
    
    @Bindable var store: StoreOf<RecipeDetailFeature>
    
    var body: some View {
        VStack {
            MultiThumbSelectionView(
                selectedThumb: $store.recipe.selectedThumb.sending(\.thumbPressed)
            )
            Text("Recipe details go here")
                .navigationTitle(store.recipe.name)
                .padding()
            
            List(store.related) { recipe in
                Button(recipe.name) {
                    store.send(.relatedRecipeSelected(recipe))
                }
            }
            
            Spacer()
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

@Reducer
struct RecipeDetailFeature {
    
    @ObservableState
    struct State: Equatable {
        @Shared var recipes: [Recipe]
        var recipe: Recipe
        var related: [Recipe] = [Recipe]()
    }
    
    enum Action {
        case thumbPressed(Recipe.ThumbSelection?)
        case relatedRecipeSelected(Recipe)
        case onAppear
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .thumbPressed(selection):
                state.recipe.selectedThumb = selection
                if let index = state.recipes.firstIndex(where: { $0.id == state.recipe.id }) {
                    state.recipes[index] = state.recipe
                }
                return .none
                
            case .relatedRecipeSelected:
                // navigation handled by root
                return .none
                
            case .onAppear:
                state.related = state.recipe.related.compactMap { recipeId in
                    state.recipes.first { recipe in
                        recipe.id == recipeId
                    }
                }
                return .none
            }
        }
    }
}
