import SwiftUI

struct RandomPokemonView: View {
    @StateObject private var viewModel = SharedPokemonViewModel.shared
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        switch viewModel.state {
                        case .loading:
                            PokemonLoadingView()
                                .frame(minHeight: 500) // Add minimum height for loading state
                            
                        case .loaded:
                            if let pokemon = viewModel.pokemon {
                                VStack(spacing: 20) {
                                    // Pokemon card with animation
                                    PokemonCard(pokemon: pokemon, showDetails: true)
                                        .frame(width: 280)
                                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
                                    
                                    // Description section
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("About")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Text(viewModel.pokemonDescription)
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    )
                                    
                                    // Action buttons section
                                    VStack(spacing: 15) {
                                        // New Random Button
                                        Button(action: getRandomPokemon) {
                                            HStack {
                                                Image(systemName: "dice")
                                                    .font(.headline)
                                                Text("New Random Pokémon")
                                                    .font(.headline)
                                            }
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.blue)
                                            )
                                        }
                                        
                                        // View Details Button
                                        NavigationLink {
                                            // Create a new view model for detail view
                                            let detailViewModel = PokemonViewModel()
                                            if let pokemon = viewModel.pokemon {
                                                detailViewModel.pokemon = pokemon
                                                detailViewModel.species = viewModel.species
                                                detailViewModel.evolutionChain = viewModel.evolutionChain
                                                detailViewModel.state = .loaded
                                                detailViewModel.bookmarkedPokemon = viewModel.bookmarkedPokemon
                                            }
                                            
                                            return PokemonDetailView(viewModel: detailViewModel)
                                                .onDisappear {
                                                    // Update shared model when returning
                                                    DispatchQueue.main.async {
                                                        viewModel.loadBookmarkedPokemon()
                                                    }
                                                }
                                        } label: {
                                            HStack {
                                                Image(systemName: "info.circle")
                                                    .font(.headline)
                                                Text("View Full Details")
                                                    .font(.headline)
                                            }
                                            .foregroundColor(.blue)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.blue, lineWidth: 2)
                                            )
                                        }
                                        
                                        // Bookmark Button
                                        Button(action: {
                                            if let pokemon = viewModel.pokemon {
                                                viewModel.toggleBookmark(for: pokemon.id)
                                                // Immediately reload bookmarks to update all views
                                                viewModel.loadBookmarkedPokemon()
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: viewModel.pokemon.map { viewModel.isBookmarked($0.id) ? "bookmark.fill" : "bookmark" } ?? "bookmark")
                                                    .font(.headline)
                                                Text(viewModel.pokemon.map { viewModel.isBookmarked($0.id) ? "Remove from Favorites" : "Add to Favorites" } ?? "Add to Favorites")
                                                    .font(.headline)
                                            }
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.orange)
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                .padding()
                                .onAppear {
                                    // Trigger animation when a new Pokemon is loaded
                                    isAnimating = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isAnimating = false
                                    }
                                }
                            }
                            
                        case .error(let error):
                            ErrorView(error: error) {
                                getRandomPokemon()
                            }
                            .frame(minHeight: 500) // Add minimum height for error state
                            
                        case .empty:
                            // Initial state - prompt to get a random Pokemon
                            VStack(spacing: 20) {
                                Image(systemName: "questionmark.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.blue)
                                
                                Text("Discover a Random Pokémon")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Tap the button below to get a random Pokémon from the Pokédex!")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button(action: getRandomPokemon) {
                                    HStack {
                                        Image(systemName: "dice")
                                            .font(.headline)
                                        Text("Get Random Pokémon")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue)
                                    )
                                }
                                .padding(.top, 10)
                            }
                            .padding()
                            .frame(minHeight: 500) // Add minimum height for empty state
                        }
                    }
                    .padding(.bottom, 20) // Add padding at the bottom for better scrolling
                }
            }
            .navigationTitle("Random Pokémon")
        }
        .onAppear {
            if viewModel.state == .empty {
                getRandomPokemon()
            }
        }
    }
    
    // Function to get a random Pokemon
    private func getRandomPokemon() {
        viewModel.fetchRandomPokemon()
    }
}

// Preview
struct RandomPokemonView_Previews: PreviewProvider {
    static var previews: some View {
        RandomPokemonView()
    }
} 