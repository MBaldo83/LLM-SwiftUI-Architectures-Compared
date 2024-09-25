## Setup 
You need to Add The Composable Architecture as a dependency see [Getting Started](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/gettingstarted)

## Prompts
---
> I want to build an app that has a list of recipes, and each recipe in the list can be seleected to display the recipe details. Using The Composable Architecture (TCA) architecture described here @https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture, navigation described here @https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/navigation and sharing state described here @https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/sharingstate please describe the main structs and classes I need to build to create these 2 views

---
> Can you change RecipeListView to use the latest TCA syntax where store is Bindable, and we no longer need WithViewStore

---
> Please update RecipeListFeature to use the latest TCA syntax making use of the Reducer macro 

---
> update RecipeListView to use a NavigationStack as described in Stack Based Navigation here: @https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/stackbasednavigation 

--- 
(debugging)
> Initializer 'init(path:root:destination:fileID:filePath:line:column:)' requires that 'RecipeDetailFeature.State' conform to 'ObservableState'

---
(debugging)
> Missing argument for parameter 'store' in call

---
> update Recipe to have an array of related recipes linked using the recipe id

---
(debugging)
> Value of type 'Recipe' has no member 'with'

---
> update recipe to have a property thumbSelection that is an optional enum ThumbSelection with cases thumbsUp and thumbsDown

---
> update RecipeListView to use a MultiThumbSelectionView allowing the user to give a recipe a thumbs up or a thumbs down

---
> Provide a List of related recipes in the RecipeDetailView, allowing 
the user to navigate to any related recipe

---
> update RecipeDetailView to use the latest TCA syntax where store is Bindable and we no longer need WithViewStore

---

Notes:
- The different syntax for old vs new versions of TCA caused an issue where the code was written 1st using the old syntax. Without knowledge of the different versions of TCA, you wouldn't know to ask the LLM to update to the new syntax
- The LLM & Cursor was able to cope with TCA architecture and delivered a working solution
- If you are using a more complex architecture pattern like TCA (eg. has multiple version, integrates with dependencies, uses non vanilla Swift constructs), and you are unfamiliar with the architecture that you are trying to implement then you shouldn't rely on your LLM assistan to support you on this learning curve. Unless you know the right questions to ask, and are able to provide the right prompt to move the solution towards latest best practice, the result could be out of date, or broken.
- your choice of architecture should be driven by what you believe is the right architecture for maintaining the software you are building. Not directed by the AI tool you're using. 


Tools used:
- Cursor AI Version: 0.41.2
  - LLM: claude-3.5-sonnet
- VSCode Version: 1.91.1
- Xcode 15.4
- iOS 17.5

Time taken to complete app: 
Number of build errors during process: 