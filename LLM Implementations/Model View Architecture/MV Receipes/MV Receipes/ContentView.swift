import SwiftUI

@main
struct RecipeApp: App {
    @StateObject private var recipeModel = RecipeModel()
    
    var body: some Scene {
        WindowGroup {
            RecipeListView()
                .environmentObject(recipeModel)
        }
    }
}

struct RecipeListView: View {
    @EnvironmentObject var recipeModel: RecipeModel
    
    var body: some View {
        NavigationView {
            List(recipeModel.recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipeId: recipe.id)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                            if let rating = recipe.rating {
                                Image(systemName: rating == .thumbsUp ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                                    .foregroundColor(rating == .thumbsUp ? .green : .red)
                            }
                        }
                        Spacer()
                        MultiThumbSelectionView(
                            selectedThumb: Binding(
                                get: { recipe.rating },
                                set: { newRating in
                                    recipeModel.updateRating(for: recipe.id, rating: newRating)
                                }
                            )
                        )
                        .frame(width: 80, height: 30)
                    }
                }
            }
            .navigationTitle("Recipes")
        }
        .onAppear {
            recipeModel.fetchRecipes()
        }
    }
}

struct RecipeDetailView: View {
    @EnvironmentObject var recipeModel: RecipeModel
    let recipeId: UUID
    
    var body: some View {
        if let recipe = recipeModel.getRecipe(id: recipeId) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(recipe.name)
                        .font(.title)
                    
                    MultiThumbSelectionView(
                        selectedThumb: Binding(
                            get: { recipe.rating },
                            set: { newRating in
                                recipeModel.updateRating(for: recipe.id, rating: newRating)
                            }
                        )
                    )
                    .frame(width: 80, height: 30)
                    
                    Text("Ingredients:")
                        .font(.headline)
                    ForEach(recipe.ingredients, id: \.self) { ingredient in
                        Text("• \(ingredient)")
                    }
                    
                    Text("Instructions:")
                        .font(.headline)
                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                        Text("\(index + 1). \(instruction)")
                    }
                    
                    Text("Related Recipes:")
                        .font(.headline)
                    ForEach(recipeModel.getRelatedRecipes(for: recipe)) { relatedRecipe in
                        NavigationLink(destination: RecipeDetailView(recipeId: relatedRecipe.id)) {
                            Text(relatedRecipe.name)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(recipe.name)
        } else {
            Text("Recipe not found")
        }
    }
}

struct Recipe: Identifiable {
    let id: UUID
    let name: String
    let ingredients: [String]
    let instructions: [String]
    var rating: Rating?
    let relatedRecipeIds: [UUID]?
    
    enum Rating {
        case thumbsUp
        case thumbsDown
    }
}

class RecipeModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    
    func fetchRecipes() {
        let applePieId = UUID()
        let baklavaId = UUID()
        let boloRoloId = UUID()
        let chocolateCracklesId = UUID()
        
        recipes = [
            Recipe(id: applePieId, name: "Apple Pie", ingredients: ["Apples", "Sugar", "Flour", "Butter"], instructions: ["Prepare filling", "Make crust", "Bake"], relatedRecipeIds: [baklavaId]),
            Recipe(id: baklavaId, name: "Baklava", ingredients: ["Phyllo dough", "Nuts", "Honey", "Butter"], instructions: ["Layer phyllo", "Add nut mixture", "Bake", "Pour syrup"], relatedRecipeIds: [applePieId, boloRoloId]),
            Recipe(id: boloRoloId, name: "Bolo Rolo", ingredients: ["Chocolate cake", "Caramel", "Cream"], instructions: ["Bake cake", "Make caramel", "Roll and fill"], relatedRecipeIds: [baklavaId, chocolateCracklesId]),
            Recipe(id: chocolateCracklesId, name: "Chocolate Crackles", ingredients: ["Rice bubbles", "Cocoa", "Coconut oil", "Icing sugar"], instructions: ["Melt ingredients", "Mix with rice bubbles", "Spoon into patty cases", "Refrigerate"], relatedRecipeIds: [boloRoloId])
        ]
    }
    
    func getRecipe(id: UUID) -> Recipe? {
        return recipes.first { $0.id == id }
    }
    
    func updateRating(for id: UUID, rating: Recipe.Rating?) {
        if let index = recipes.firstIndex(where: { $0.id == id }) {
            recipes[index].rating = rating
        }
    }
    
    func getRelatedRecipes(for recipe: Recipe) -> [Recipe] {
        guard let relatedIds = recipe.relatedRecipeIds else {
            return []
        }
        return recipes.filter { relatedIds.contains($0.id) }
    }
}
