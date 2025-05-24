import SwiftUI

struct PokemonDetailView: View {
    @ObservedObject var viewModel: PokemonViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                switch viewModel.state {
                case .loading:
                    PokemonLoadingView()
                    
                case .loaded:
                    if let pokemon = viewModel.pokemon {
                        // Pokemon header with image and basic info
                        headerView(for: pokemon)
                        
                        // Pokemon description from species data
                        descriptionView
                        
                        // Pokemon stats
                        statsView(for: pokemon)
                        
                        // Evolution chain (if available)
                        evolutionChainView
                    }
                    
                case .error(let error):
                    ErrorView(error: error) {
                        if let pokemon = viewModel.pokemon {
                            viewModel.fetchPokemon(idOrName: String(pokemon.id))
                        }
                    }
                    
                case .empty:
                    Text("Select a Pokémon to see details")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.pokemon?.name.capitalized ?? "Pokémon Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let pokemon = viewModel.pokemon {
                    Button(action: {
                        // Toggle bookmark in this view model
                        viewModel.toggleBookmark(for: pokemon.id)
                        
                        // Also toggle in the shared model to keep them in sync
                        if SharedPokemonViewModel.shared !== viewModel {
                            SharedPokemonViewModel.shared.toggleBookmark(for: pokemon.id)
                        }
                    }) {
                        Image(systemName: viewModel.isBookmarked(pokemon.id) ? "bookmark.fill" : "bookmark")
                    }
                }
            }
        }
    }
    
    // MARK: - Component Views
    
    private func headerView(for pokemon: Pokemon) -> some View {
        VStack(spacing: 16) {
            // Pokemon image
            AsyncImage(url: pokemon.mainImageURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                } else if phase.error != nil {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .foregroundColor(.gray)
                } else {
                    ProgressView()
                        .frame(height: 200)
                }
            }
            .background(
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 220, height: 220)
            )
            
            // Pokemon ID and name
            VStack(spacing: 4) {
                Text("#\(pokemon.id)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(pokemon.name.capitalized)
                    .font(.title)
                    .fontWeight(.bold)
                
                if viewModel.isLegendary {
                    Text("Legendary Pokémon")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.2))
                        )
                } else if viewModel.isMythical {
                    Text("Mythical Pokémon")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.purple.opacity(0.2))
                        )
                }
            }
            
            // Pokemon types
            HStack(spacing: 12) {
                ForEach(pokemon.typeNames, id: \.self) { typeName in
                    Text(typeName)
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(typeColor(for: typeName.lowercased()))
                        )
                        .foregroundColor(.white)
                }
            }
            
            // Size info
            HStack(spacing: 20) {
                VStack {
                    Text("Height")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(Double(pokemon.height) / 10) m")
                        .font(.headline)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack {
                    Text("Weight")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(Double(pokemon.weight) / 10) kg")
                        .font(.headline)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .padding(.bottom, 10)
    }
    
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(viewModel.pokemonCategory)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(viewModel.pokemonDescription)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private func statsView(for pokemon: Pokemon) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Base Stats")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(["hp", "attack", "defense", "special-attack", "special-defense", "speed"], id: \.self) { statName in
                let value = pokemon.getStatValue(forName: statName)
                
                HStack {
                    Text(formatStatName(statName))
                        .font(.subheadline)
                        .frame(width: 100, alignment: .leading)
                    
                    Text("\(value)")
                        .font(.headline)
                        .frame(width: 40, alignment: .trailing)
                    
                    // Stat bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)
                        
                        // Calculate width based on stat value (max value is typically 255)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(statColor(for: value))
                            .frame(width: CGFloat(value) / 255.0 * 200, height: 8)
                    }
                    .frame(height: 8)
                }
                .padding(.vertical, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var evolutionChainView: some View {
        Group {
            if let evolutionChain = viewModel.evolutionChain {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Evolution Chain")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if evolutionChain.evolutionStages.isEmpty {
                        Text("This Pokémon does not evolve.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    } else {
                        // Simple evolution chain display
                        ForEach(evolutionChain.evolutionStages) { stage in
                            evolutionStageView(stage)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
            }
        }
    }
    
    private func evolutionStageView(_ stage: PokemonEvolutionChain.EvolutionStage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(stage.pokemonName)
                    .font(.headline)
                
                Spacer()
                
                if let id = stage.pokemonId {
                    Text("#\(id)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if !stage.evolvesTo.isEmpty {
                ForEach(stage.evolvesTo) { nextStage in
                    HStack {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.blue)
                        
                        if let requirements = nextStage.evolutionDetails {
                            Text(requirements.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.leading)
                    
                    evolutionStageView(nextStage)
                        .padding(.leading, 20)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatStatName(_ statName: String) -> String {
        switch statName {
        case "hp": return "HP"
        case "attack": return "Attack"
        case "defense": return "Defense"
        case "special-attack": return "Sp. Attack"
        case "special-defense": return "Sp. Defense"
        case "speed": return "Speed"
        default: return statName.capitalized
        }
    }
    
    private func statColor(for value: Int) -> Color {
        if value < 50 {
            return Color.red
        } else if value < 80 {
            return Color.orange
        } else if value < 120 {
            return Color.green
        } else {
            return Color.blue
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
struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PokemonViewModel()
        // Use a mock Pokemon for preview
        viewModel.pokemon = Pokemon(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            sprites: Pokemon.Sprites(
                frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
                other: Pokemon.Sprites.OtherSprites(
                    officialArtwork: Pokemon.Sprites.OtherSprites.OfficialArtwork(
                        frontDefault: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png"
                    )
                )
            ),
            types: [
                Pokemon.PokemonType(
                    slot: 1,
                    type: Pokemon.PokemonType.TypeInfo(
                        name: "electric",
                        url: "https://pokeapi.co/api/v2/type/13/"
                    )
                )
            ],
            stats: [
                Pokemon.Stat(
                    baseStat: 35,
                    effort: 0,
                    stat: Pokemon.Stat.StatInfo(
                        name: "hp",
                        url: "https://pokeapi.co/api/v2/stat/1/"
                    )
                ),
                Pokemon.Stat(
                    baseStat: 55,
                    effort: 0,
                    stat: Pokemon.Stat.StatInfo(
                        name: "attack",
                        url: "https://pokeapi.co/api/v2/stat/2/"
                    )
                ),
                Pokemon.Stat(
                    baseStat: 40,
                    effort: 0,
                    stat: Pokemon.Stat.StatInfo(
                        name: "defense",
                        url: "https://pokeapi.co/api/v2/stat/3/"
                    )
                ),
                Pokemon.Stat(
                    baseStat: 50,
                    effort: 0,
                    stat: Pokemon.Stat.StatInfo(
                        name: "special-attack",
                        url: "https://pokeapi.co/api/v2/stat/4/"
                    )
                ),
                Pokemon.Stat(
                    baseStat: 50,
                    effort: 0,
                    stat: Pokemon.Stat.StatInfo(
                        name: "special-defense",
                        url: "https://pokeapi.co/api/v2/stat/5/"
                    )
                ),
                Pokemon.Stat(
                    baseStat: 90,
                    effort: 2,
                    stat: Pokemon.Stat.StatInfo(
                        name: "speed",
                        url: "https://pokeapi.co/api/v2/stat/6/"
                    )
                )
            ]
        )
        viewModel.state = .loaded
        
        return NavigationView {
            PokemonDetailView(viewModel: viewModel)
        }
    }
} 