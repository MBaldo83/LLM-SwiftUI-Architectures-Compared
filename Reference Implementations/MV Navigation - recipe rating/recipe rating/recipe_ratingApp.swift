import SwiftUI

@main
struct recipe_ratingApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeListView()
                .environmentObject(Model())
        }
    }
}
