// https://developer.apple.com/videos/play/wwdc2022/10054/

import SwiftUI

// Pushable stack
struct RecipeListView: View {
    @State private var path: [Model.Recipe] = []
    @EnvironmentObject private var model: Model
    
    var body: some View {
        NavigationStack(path: $path) {
            List(model.recipes) { recipe in
                NavigationLink(value: recipe) {
                    HStack {
                        MultiThumbSelectionView(selectedThumb: Binding(get: {
                            recipe.selectedThumb
                        }, set: { [recipe] selection in
                            var mRecipe = recipe
                            mRecipe.selectedThumb = selection
                            model.update(recipe: mRecipe)
                        })
                        )
                        Text(recipe.name)
                    }
                    .padding()
                }
            }
            .navigationTitle("Recipes")
            .navigationDestination(for: Model.Recipe.self) { recipe in
                RecipeDetail(recipe: recipe)
            }
        }
    }
}

// Helpers for code example
struct RecipeDetail: View {
    
    @EnvironmentObject private var model: Model
    @State var recipe: Model.Recipe
    
    var body: some View {
        VStack {
            MultiThumbSelectionView(selectedThumb: $recipe.selectedThumb)
            Text("Recipe details go here")
                .navigationTitle(recipe.name)
                .padding()
    
            List(recipe.related.compactMap { model[$0] }) { recipe in
                NavigationLink(recipe.name, value: recipe)
            }
            Spacer()
        }
        .onChange(of: recipe) { oldValue, newValue in
            model.update(recipe: newValue)
        }
    }
}

struct PushableStack_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView()
    }
}
