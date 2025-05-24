import SwiftUI

struct BookmarkedPokemonView: View {
    @StateObject private var viewModel = SharedPokemonViewModel.shared
    @State private var showingDeleteConfirmation = false
    @State private var pokemonToDelete: Int?
    
    // Store the observer token to properly manage lifecycle
    @State private var notificationToken: NSObjectProtocol?
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.bookmarkedPokemon.isEmpty {
                    // Empty state
                    emptyStateView
                } else {
                    // List of bookmarked Pokemon
                    bookmarkedListView
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: {
                            showingDeleteConfirmation = true
                        }) {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .disabled(viewModel.bookmarkedPokemon.isEmpty)
                }
            }
            .alert("Clear All Favorites", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    clearAllBookmarks()
                }
            } message: {
                Text("Are you sure you want to remove all your favorite Pokémon?")
            }
        }
        .onAppear {
            // Load bookmarks when the view appears
            viewModel.loadBookmarkedPokemon()
            
            // Only set up the notification observer if it doesn't exist
            if notificationToken == nil {
                notificationToken = NotificationCenter.default.addObserver(
                    forName: .pokemonBookmarksChanged,
                    object: nil,
                    queue: .main
                ) { _ in
                    // When a bookmark changes, update the view model's bookmarks list
                    DispatchQueue.main.async {
                        if let userDefaultsBookmarks = UserDefaults.standard.array(forKey: "bookmarkedPokemon") as? [Int] {
                            self.viewModel.bookmarkedPokemon = userDefaultsBookmarks
                        }
                    }
                }
            }
        }
        .onDisappear {
            // Remove notification observer when view disappears
            if let token = notificationToken {
                NotificationCenter.default.removeObserver(token)
                notificationToken = nil
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.slash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Bookmark your favorite Pokémon to see them here!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            NavigationLink(destination: RandomPokemonView()) {
                HStack {
                    Image(systemName: "dice")
                    Text("Find Random Pokémon")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue)
                )
            }
            .padding(.top)
        }
        .padding()
    }
    
    private var bookmarkedListView: some View {
        List {
            ForEach(viewModel.bookmarkedPokemon, id: \.self) { pokemonId in
                BookmarkedPokemonRow(pokemonId: pokemonId, viewModel: viewModel)
            }
        }
        .refreshable {
            // Refresh the bookmarks list
            viewModel.loadBookmarkedPokemon()
        }
        .navigationDestination(for: Pokemon.self) { pokemon in
            // Create a new view model with the pokemon data
            let detailViewModel = createDetailViewModel(for: pokemon)
            
            PokemonDetailView(viewModel: detailViewModel)
                .onDisappear {
                    // When returning from detail view, check if there are bookmark changes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        // Check if the UserDefaults value has changed
                        if let userDefaultsBookmarks = UserDefaults.standard.array(forKey: "bookmarkedPokemon") as? [Int],
                           Set(userDefaultsBookmarks) != Set(viewModel.bookmarkedPokemon) {
                            // Update the shared view model with the latest bookmarks
                            viewModel.bookmarkedPokemon = userDefaultsBookmarks
                        }
                    }
                }
        }
        .alert("Remove from Favorites", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                if let id = pokemonToDelete {
                    viewModel.toggleBookmark(for: id)
                    pokemonToDelete = nil
                }
            }
        } message: {
            Text("Are you sure you want to remove this Pokémon from your favorites?")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createDetailViewModel(for pokemon: Pokemon) -> PokemonViewModel {
        // Create a new view model instance instead of reusing the shared one
        let detailViewModel = PokemonViewModel()
        detailViewModel.pokemon = pokemon
        detailViewModel.state = .loaded
        
        // Copy bookmarks from shared model
        detailViewModel.bookmarkedPokemon = viewModel.bookmarkedPokemon
        
        // Fetch species data for this Pokemon
        detailViewModel.fetchPokemonSpecies(id: pokemon.id)
        
        return detailViewModel
    }
    
    private func clearAllBookmarks() {
        for id in viewModel.bookmarkedPokemon {
            viewModel.toggleBookmark(for: id)
        }
    }
}

// MARK: - BookmarkedPokemonRow

struct BookmarkedPokemonRow: View {
    let pokemonId: Int
    let viewModel: PokemonViewModel
    
    @State private var pokemon: Pokemon?
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
                    .frame(width: 60, height: 60)
            } else if let pokemon = pokemon {
                // Pokemon image
                AsyncImage(url: pokemon.mainImageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                }
                .background(
                    Circle()
                        .fill(Color(.systemGray6))
                        .frame(width: 70, height: 70)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(pokemon.name.capitalized)
                        .font(.headline)
                    
                    // Pokemon types
                    HStack {
                        ForEach(pokemon.typeNames, id: \.self) { type in
                            Text(type)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(typeColor(for: type.lowercased()))
                                )
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.leading, 8)
                
                Spacer()
                
                // Use NavigationLink with value parameter
                NavigationLink(value: pokemon) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            } else if let error = error {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text("Error loading #\(pokemonId)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .onTapGesture {
                    loadPokemon()
                }
            } else {
                Text("#\(pokemonId)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: {
                viewModel.toggleBookmark(for: pokemonId)
            }) {
                Label("Remove", systemImage: "trash")
            }
        }
        .onAppear {
            loadPokemon()
        }
    }
    
    private func loadPokemon() {
        isLoading = true
        error = nil
        
        NetworkManager.shared.fetchPokemon(idOrName: String(pokemonId)) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let fetchedPokemon):
                    self.pokemon = fetchedPokemon
                case .failure(let fetchError):
                    self.error = fetchError
                }
            }
        }
    }
    
    private func typeColor(for typeName: String) -> Color {
        let typeColors: [String: Color] = [
            "normal": Color(.systemGray),
            "fire": Color(.systemOrange),
            "water": Color(.systemBlue),
            "electric": Color(.systemYellow),
            "grass": Color(.systemGreen),
            "ice": Color(.systemTeal),
            "fighting": Color(.systemRed),
            "poison": Color(.systemPurple),
            "ground": Color(.systemBrown),
            "flying": Color(.systemIndigo),
            "psychic": Color(.systemPink),
            "bug": Color(.systemMint),
            "rock": Color(.systemGray4),
            "ghost": Color(.systemIndigo),
            "dragon": Color(.systemPurple),
            "dark": Color(.systemGray6),
            "steel": Color(.systemGray3),
            "fairy": Color(.systemPink)
        ]
        
        return typeColors[typeName] ?? Color(.systemGray)
    }
}

// Preview
struct BookmarkedPokemonView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkedPokemonView()
    }
} 