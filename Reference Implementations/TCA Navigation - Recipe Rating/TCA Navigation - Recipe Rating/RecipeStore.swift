import Foundation
import ComposableArchitecture

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

let builtInRecipes: [Recipe] = {
    var recipes: [String: Recipe] = [
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

