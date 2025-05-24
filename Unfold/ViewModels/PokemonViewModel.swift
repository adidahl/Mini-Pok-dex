import Foundation
import Combine

// Define view states for the UI
enum ViewState: Equatable {
    case loading
    case loaded
    case error(Error)
    case empty
    
    // Implement Equatable conformance
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded, .loaded):
            return true
        case (.empty, .empty):
            return true
        case (.error, .error):
            // Note: We can't compare the actual errors directly,
            // so we just check if both are error states
            return true
        default:
            return false
        }
    }
}

class PokemonViewModel: ObservableObject {
    // Published properties for UI updates
    @Published var pokemon: Pokemon?
    @Published var species: PokemonSpecies?
    @Published var evolutionChain: PokemonEvolutionChain?
    @Published var state: ViewState = .empty
    @Published var bookmarkedPokemon: [Int] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load bookmarked Pokemon from UserDefaults
        loadBookmarkedPokemon()
    }
    
    // MARK: - Data Fetching
    
    /// Fetch a Pokemon by ID or name
    /// - Parameter idOrName: Pokemon ID or name
    func fetchPokemon(idOrName: String) {
        state = .loading
        
        NetworkManager.shared.fetchPokemon(idOrName: idOrName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let pokemon):
                    self?.pokemon = pokemon
                    self?.fetchPokemonSpecies(id: pokemon.id)
                case .failure(let error):
                    self?.state = .error(error)
                }
            }
        }
    }
    
    /// Fetch Pokemon species data
    /// - Parameter id: Pokemon ID
    func fetchPokemonSpecies(id: Int) {
        NetworkManager.shared.fetchPokemonSpecies(id: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let species):
                    self?.species = species
                    if let evolutionChainId = species.evolutionChain.id {
                        self?.fetchEvolutionChain(id: evolutionChainId)
                    } else {
                        self?.state = .loaded
                    }
                case .failure(let error):
                    self?.state = .error(error)
                }
            }
        }
    }
    
    /// Fetch evolution chain data
    /// - Parameter id: Evolution chain ID
    private func fetchEvolutionChain(id: Int) {
        NetworkManager.shared.fetchEvolutionChain(id: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let evolutionChain):
                    let simplifiedChain = PokemonEvolutionChain.fromAPIResponse(evolutionChain)
                    self?.evolutionChain = simplifiedChain
                    self?.state = .loaded
                case .failure(let error):
                    // If evolution chain fails, we still show the Pokemon
                    print("Error fetching evolution chain: \(error)")
                    self?.state = .loaded
                }
            }
        }
    }
    
    /// Fetch a random Pokemon
    func fetchRandomPokemon() {
        state = .loading
        
        NetworkManager.shared.fetchRandomPokemon { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let pokemon):
                    self?.pokemon = pokemon
                    self?.fetchPokemonSpecies(id: pokemon.id)
                case .failure(let error):
                    self?.state = .error(error)
                }
            }
        }
    }
    
    // MARK: - Bookmarks Management
    
    /// Toggle bookmark status for a Pokemon
    /// - Parameter pokemonId: Pokemon ID to bookmark/unbookmark
    func toggleBookmark(for pokemonId: Int) {
        // Use DispatchQueue.main.async to avoid publishing changes during view updates
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Check if we need to make any changes
            let currentlyBookmarked = self.isBookmarked(pokemonId)
            let newBookmarks: [Int]
            
            if currentlyBookmarked {
                // Only modify if needed
                if self.bookmarkedPokemon.contains(pokemonId) {
                    newBookmarks = self.bookmarkedPokemon.filter { $0 != pokemonId }
                    self.bookmarkedPokemon = newBookmarks
                    self.saveBookmarkedPokemon()
                    
                    // Post notification when bookmarks change, but limit frequency
                    NotificationCenter.default.post(name: .pokemonBookmarksChanged, object: nil)
                }
            } else {
                // Only add if not already there
                if !self.bookmarkedPokemon.contains(pokemonId) {
                    newBookmarks = self.bookmarkedPokemon + [pokemonId]
                    self.bookmarkedPokemon = newBookmarks
                    self.saveBookmarkedPokemon()
                    
                    // Post notification when bookmarks change, but limit frequency
                    NotificationCenter.default.post(name: .pokemonBookmarksChanged, object: nil)
                }
            }
        }
    }
    
    /// Check if a Pokemon is bookmarked
    /// - Parameter pokemonId: Pokemon ID to check
    /// - Returns: True if bookmarked, false otherwise
    func isBookmarked(_ pokemonId: Int) -> Bool {
        return bookmarkedPokemon.contains(pokemonId)
    }
    
    /// Load bookmarked Pokemon from UserDefaults
    func loadBookmarkedPokemon() {
        // Use a static property to track the last time we loaded bookmarks
        // to avoid excessive reloading
        if let data = UserDefaults.standard.array(forKey: "bookmarkedPokemon") as? [Int] {
            // Only update if the data has actually changed
            let dataHasChanged = Set(data) != Set(bookmarkedPokemon)
            
            if dataHasChanged {
                // Use DispatchQueue.main.async to avoid publishing changes during view updates
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.bookmarkedPokemon = data
                }
            }
        }
    }
    
    /// Save bookmarked Pokemon to UserDefaults
    private func saveBookmarkedPokemon() {
        UserDefaults.standard.set(bookmarkedPokemon, forKey: "bookmarkedPokemon")
    }
    
    // MARK: - Helper Methods
    
    /// Reset the view state
    func reset() {
        pokemon = nil
        species = nil
        evolutionChain = nil
        state = .empty
    }
}

// MARK: - Extensions for convenience

extension PokemonViewModel {
    /// Pokemon description from species data
    var pokemonDescription: String {
        return species?.englishDescription ?? "No description available."
    }
    
    /// Pokemon category from species data
    var pokemonCategory: String {
        return species?.category ?? "Unknown"
    }
    
    /// Check if Pokemon is legendary
    var isLegendary: Bool {
        return species?.isLegendary ?? false
    }
    
    /// Check if Pokemon is mythical
    var isMythical: Bool {
        return species?.isMythical ?? false
    }
}

// Shared ViewModel instance for app-wide use
class SharedPokemonViewModel {
    static let shared = PokemonViewModel()
}

// MARK: - Notification Extension
extension Notification.Name {
    static let pokemonBookmarksChanged = Notification.Name("pokemonBookmarksChanged")
} 