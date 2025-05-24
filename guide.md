# Unfold Mini Pokédex Development Guide

This guide outlines the step-by-step process to build a mini Pokédex iOS app using Swift and SwiftUI. Each task is designed to be a small atomic unit that can be executed sequentially.

> **Important**: After completing each meaningful task, commit and push your changes to GitHub. This creates a history of all changes and allows you to revert if something goes wrong. Use descriptive commit messages that clearly indicate what was implemented.
>
> Example git workflow after completing a task:
> ```bash
> git add .
> git commit -m "Implement [Task Name]: [Brief description of what was done]"
> git push origin [branch-name]
> ```

## Project Setup and Foundation

- [ ] Task 1: Initial Xcode project with SwiftUI already exist, so use existing bolier plate
  - Organize project with folders: Models, Views, ViewModels, Services, Utilities
  - *Commit after creating the folder structure*

- [ ] Task 2: Create a README.md with project description, features, and setup instructions
  - Include project overview, features list, installation guide, and usage instructions
  - Document API usage and attribution to PokéAPI
  - *Commit after creating the README*

- [ ] Task 3: Set up Git version control with initial commit
  - Initialize Git repository
  - Create .gitignore file for Xcode/Swift projects
  - Make initial commit with project structure
  - *This is already done since we're working with an existing repository*

## Core Models and API Integration

- [ ] Task 4: Create Pokemon data model with essential properties
  - Create `Pokemon.swift` with properties for id, name, image URLs, types, etc.
  - Example structure:
  ```swift
  struct Pokemon: Identifiable, Codable {
      let id: Int
      let name: String
      let sprites: Sprites
      let types: [PokemonType]
      
      struct Sprites: Codable {
          let frontDefault: String
          
          enum CodingKeys: String, CodingKey {
              case frontDefault = "front_default"
          }
      }
      
      struct PokemonType: Codable {
          let type: TypeInfo
          
          struct TypeInfo: Codable {
              let name: String
          }
      }
  }
  ```
  - *Commit after creating the Pokemon model*

- [ ] Task 5: Create PokemonEvolution model to handle evolution chains
  - Create model to represent evolution chains from the PokeAPI
  - Include properties for evolution requirements and stage tracking
  - *Commit after creating the evolution model*

- [ ] Task 6: Create NetworkManager to handle API requests to PokeAPI
  - Implement a networking layer using URLSession
  - Create endpoint enum for different API paths
  - Implement error handling and response parsing
  - Example structure:
  ```swift
  class NetworkManager {
      static let shared = NetworkManager()
      private let baseURL = "https://pokeapi.co/api/v2"
      
      func fetchData<T: Decodable>(from endpoint: Endpoint, completion: @escaping (Result<T, Error>) -> Void) {
          // Implementation with URLSession
      }
      
      enum Endpoint {
          case pokemon(id: Int)
          case evolutionChain(id: Int)
          case randomPokemon
          
          var path: String {
              // Return appropriate path based on case
          }
      }
  }
  ```
  - *Commit after implementing the NetworkManager*

- [ ] Task 7: Implement the fetch function for a single Pokemon
  - Create function to fetch Pokemon details by ID or name
  - Parse JSON response into Pokemon model
  - *Commit after implementing the Pokemon fetch function*

- [ ] Task 8: Implement the fetch function for Pokemon evolution chains
  - Create function to fetch evolution chain data
  - Handle the nested JSON structure of evolution chains
  - *Commit after implementing the evolution chain fetch function*

- [ ] Task 9: Add error handling for API requests
  - Create custom Error types
  - Implement retry logic for failed requests
  - Add proper error feedback to the UI
  - *Commit after implementing error handling*

## UI Components

- [ ] Task 10: Design and implement a PokemonCard view to display basic Pokemon info
  - Create reusable PokemonCard component with image, name, and type
  - Add animations and styling for a kid-friendly appearance
  - *Commit after implementing the PokemonCard view*

- [ ] Task 11: Create a detailed Pokemon view with complete information
  - Design a view to display all Pokemon details
  - Include sections for stats, descriptions, and evolution
  - *Commit after implementing the detailed Pokemon view*

- [ ] Task 12: Design the evolution chain visualization component
  - Create a visual representation of evolution pathways
  - Include evolution requirements in a kid-friendly format
  - *Commit after implementing the evolution chain visualization*

- [ ] Task 13: Create a loading view for data fetching states
  - Design animated loading indicators
  - Implement skeleton views for content loading
  - *Commit after implementing the loading views*

- [ ] Task 14: Implement error message views for failed requests
  - Create user-friendly error messages
  - Add retry options for failed requests
  - *Commit after implementing the error message views*

## Main Features - For Parents

- [ ] Task 15: Implement a random Pokemon generator function
  - Create function to fetch a random Pokemon
  - Ensure different Pokemon each time
  - *Commit after implementing the random Pokemon generator*

- [ ] Task 16: Create the UI for displaying a random Pokemon
  - Design the random Pokemon showcase view
  - Include transitions for Pokemon changes
  - *Commit after implementing the random Pokemon UI*

- [ ] Task 17: Add a "New Random" button to refresh the random Pokemon
  - Add button with animation
  - Implement action to fetch new random Pokemon
  - *Commit after implementing the "New Random" button*

- [ ] Task 18: Implement bookmarking functionality (data model and persistence)
  - Create BookmarkedPokemon model
  - Set up UserDefaults or CoreData for persistence
  - *Commit after implementing the bookmarking functionality*

- [ ] Task 19: Create bookmarked Pokemon list view
  - Design list view for bookmarked Pokemon
  - Include swipe actions or buttons for management
  - *Commit after implementing the bookmarked list view*

- [ ] Task 20: Add functionality to remove bookmarks
  - Implement delete functionality
  - Add confirmation dialog for deletions
  - *Commit after implementing bookmark removal*

## Main Features - For Kids

- [ ] Task 21: Design a kid-friendly, colorful UI theme
  - Create color palette with bright, accessible colors
  - Use rounded corners and playful typography
  - Add animations for interactions
  - *Commit after implementing the UI theme*

- [ ] Task 22: Create a Pokemon search function with name-based search
  - Implement search bar
  - Create filtered results display
  - *Commit after implementing the search functionality*

- [ ] Task 23: Implement fuzzy search to handle spelling mistakes
  - Add fuzzy matching algorithm
  - Prioritize close matches in results
  - *Commit after implementing fuzzy search*

- [ ] Task 24: Design and implement the Pokemon library/list view
  - Create scrollable grid or list of Pokemon
  - Include filtering and sorting options
  - *Commit after implementing the Pokemon library view*

- [ ] Task 25: Add filter functionality by Pokemon type
  - Create type selection UI
  - Implement filtering logic
  - *Commit after implementing type filtering*

- [ ] Task 26: Create a visual evolution pathway view
  - Design visual representation of evolution chains
  - Make evolution requirements easy to understand
  - *Commit after implementing the evolution pathway view*

## State Management and Persistence

- [ ] Task 27: Set up UserDefaults to store bookmarked Pokemon
  - Create UserDefaults extension for saving bookmarks
  - Implement functions to add/remove bookmarks
  - Example implementation:
  ```swift
  extension UserDefaults {
      private enum Keys {
          static let bookmarkedPokemon = "bookmarkedPokemon"
      }
      
      func saveBookmarkedPokemon(_ pokemonIds: [Int]) {
          set(pokemonIds, forKey: Keys.bookmarkedPokemon)
      }
      
      func getBookmarkedPokemon() -> [Int] {
          return object(forKey: Keys.bookmarkedPokemon) as? [Int] ?? []
      }
  }
  ```
  - *Commit after implementing UserDefaults storage*

- [ ] Task 28: Implement state management for the app using SwiftUI's @State and @StateObject
  - Create view models with @Published properties
  - Use @StateObject and @ObservedObject in views
  - *Commit after implementing state management*

- [ ] Task 29: Add persistence for last viewed Pokemon
  - Save last viewed Pokemon ID
  - Implement auto-load on app restart
  - *Commit after implementing last viewed persistence*

- [ ] Task 30: Implement caching for Pokemon data to reduce API calls
  - Create a simple caching system
  - Add expiration logic for cached data
  - *Commit after implementing caching*

## Navigation and App Structure

- [ ] Task 31: Set up TabView for main navigation (Random, Search, Bookmarks)
  - Create tab-based navigation
  - Design tab bar icons and labels
  - *Commit after implementing TabView navigation*

- [ ] Task 32: Implement navigation between list views and detail views
  - Set up NavigationStack or NavigationView
  - Configure navigation links and transitions
  - *Commit after implementing navigation between views*

- [ ] Task 33: Add transitions and animations for better UX
  - Add custom transitions between views
  - Implement animations for state changes
  - *Commit after implementing transitions and animations*

- [ ] Task 34: Create a home screen with app description and navigation options
  - Design welcome screen
  - Add quick navigation buttons to main features
  - *Commit after implementing the home screen*

## Offline Support and Performance

- [ ] Task 35: Add image caching for Pokemon sprites
  - Implement image caching system
  - Add memory management for cached images
  - *Commit after implementing image caching*

- [ ] Task 36: Implement offline support with cached data
  - Add local storage for viewed Pokemon
  - Create offline mode detection
  - *Commit after implementing offline support*

- [ ] Task 37: Add loading indicators and optimize performance
  - Audit and optimize performance
  - Add progress indicators for long operations
  - *Commit after performance optimization*

## Accessibility and Final Touches

- [ ] Task 38: Add accessibility labels and hints
  - Audit app for accessibility
  - Add VoiceOver support
  - *Commit after implementing accessibility features*

- [ ] Task 39: Implement Dynamic Type support
  - Ensure text scales properly
  - Test with different text sizes
  - *Commit after implementing Dynamic Type support*

- [ ] Task 40: Add app icon and launch screen
  - Design Pokédex-themed app icon
  - Create simple launch screen
  - *Commit after adding icon and launch screen*

- [ ] Task 41: Perform final UI polish and consistency check
  - Ensure consistent styling
  - Fix any UI glitches
  - *Commit after UI polish*

- [ ] Task 42: Write unit tests for core functionality
  - Create tests for network requests
  - Add tests for model parsing
  - Test persistence logic
  - *Commit after implementing unit tests*

- [ ] Task 43: Perform final testing on different iOS devices and fix any issues
  - Test on different screen sizes
  - Check for any device-specific issues
  - *Commit after final testing and fixes*

## Documentation and Delivery

- [ ] Task 44: Update README.md with complete instructions and feature list
  - Add screenshots
  - Include detailed usage instructions
  - *Commit after updating README*

- [ ] Task 45: Document any known issues or future improvements
  - Create issues list
  - Add potential future features
  - *Commit after documenting issues and improvements*

- [ ] Task 46: Prepare app for demonstration
  - Create demo data
  - Prepare presentation flow
  - *Commit after preparing for demonstration*

- [ ] Task 47: Create a simple user guide for the family
  - Write user-friendly instructions
  - Include screenshots and examples
  - *Commit after creating the user guide*

## Implementation Notes

- The app will use SwiftUI for UI development
- Use the REST API v2 from PokeAPI (https://pokeapi.co/docs/v2)
- Avoid using external packages when possible
- Focus on creating a clean, maintainable codebase
- Prioritize features based on core requirements

### PokeAPI Endpoints to Use

- `/pokemon/{id or name}` - Get details about a specific Pokemon
- `/pokemon-species/{id}` - Get species details including evolution chain link
- `/evolution-chain/{id}` - Get evolution chain details
- `/type/{id or name}` - Get information about Pokemon types

Remember that not all features need to be implemented for the first demo. Focus on delivering a working app with the most important features first, then expand as time allows. 