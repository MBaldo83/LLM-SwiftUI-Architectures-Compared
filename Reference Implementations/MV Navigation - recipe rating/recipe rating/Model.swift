import Foundation

class Model: ObservableObject {
    
    struct Recipe: Hashable, Identifiable {
        enum ThumbSelection {
            case thumbsUp, thumbsDown
        }
        
        var selectedThumb: ThumbSelection?
        let id = UUID()
        var name: String
        var related: [Recipe.ID] = []
        var imageName: String? = nil
    }
    
    @Published var recipes: [Recipe] = builtInRecipes
    
    subscript(recipeId: Recipe.ID) -> Recipe? {
        // A real app would want to maintain an index from identifiers to recipes
        recipes.first { recipe in
            recipe.id == recipeId
        }
    }
    
    func update(recipe: Recipe) {
        recipes.indices
            .filter { recipes[$0].id == recipe.id }
            .forEach { recipes[$0] = recipe }
    }
}

let builtInRecipes: [Model.Recipe] = {
    var recipes: [String: Model.Recipe] = [
        "Apple Pie": .init(
            name: "Apple Pie"),
        "Baklava": .init(
            name: "Baklava"),
        "Bolo de Rolo": .init(
            name: "Bolo de rolo"),
        "Chocolate Crackles": .init(
            name: "Chocolate crackles")
    ]
    
    recipes["Apple Pie"]!.related = [
        recipes["Baklava"]!.id,
        recipes["Bolo de Rolo"]!.id,
    ]
    
    recipes["Baklava"]!.related = [recipes["Bolo de Rolo"]!.id]
    recipes["Bolo de Rolo"]!.related = [recipes["Baklava"]!.id]
    
    return Array(recipes.values)
}()
