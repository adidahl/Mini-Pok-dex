import SwiftUI

struct EvolutionChainView: View {
    let evolutionChain: PokemonEvolutionChain
    var onPokemonSelected: ((Int) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Evolution Chain")
                .font(.title2)
                .fontWeight(.bold)
            
            if evolutionChain.evolutionStages.isEmpty {
                Text("This Pokémon does not evolve.")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else {
                // Visual evolution chain
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(evolutionChain.evolutionStages) { stage in
                            evolutionChainRow(stage)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    @ViewBuilder
    private func evolutionChainRow(_ stage: PokemonEvolutionChain.EvolutionStage) -> some View {
        VStack {
            // Start with the first Pokemon
            pokemonStageView(stage)
            
            // Recursively add evolution stages
            if !stage.evolvesTo.isEmpty {
                ForEach(stage.evolvesTo) { nextStage in
                    evolutionArrow(with: nextStage.evolutionDetails)
                    pokemonStageView(nextStage)
                    
                    // Continue with further evolutions if any
                    if !nextStage.evolvesTo.isEmpty {
                        ForEach(nextStage.evolvesTo) { thirdStage in
                            evolutionArrow(with: thirdStage.evolutionDetails)
                            pokemonStageView(thirdStage)
                        }
                    }
                }
            }
        }
    }
    
    private func pokemonStageView(_ stage: PokemonEvolutionChain.EvolutionStage) -> some View {
        VStack(spacing: 8) {
            if let imageUrl = stage.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                            .frame(width: 80, height: 80)
                    }
                }
            } else {
                // Default image if URL is nil
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            }
            
            Text(stage.pokemonName)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            if let id = stage.pokemonId {
                Text("#\(id)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 100)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .onTapGesture {
            if let id = stage.pokemonId {
                onPokemonSelected?(id)
            }
        }
    }
    
    private func evolutionArrow(with requirements: PokemonEvolutionChain.EvolutionStage.EvolutionRequirements?) -> some View {
        VStack(spacing: 4) {
            Image(systemName: "arrow.down")
                .font(.title3)
                .foregroundColor(.blue)
            
            if let requirements = requirements {
                Text(requirements.description)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .frame(width: 120)
            }
        }
        .padding(.vertical, 8)
    }
}

// More detailed view for showing a specific evolution path
struct DetailedEvolutionPathView: View {
    let stages: [PokemonEvolutionChain.EvolutionStage]
    var onPokemonSelected: ((Int) -> Void)?
    
    var body: some View {
        VStack(spacing: 30) {
            ForEach(0..<stages.count, id: \.self) { index in
                let stage = stages[index]
                
                VStack(spacing: 10) {
                    pokemonView(stage)
                    
                    if index < stages.count - 1 {
                        let nextStage = stages[index + 1]
                        
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            
                            if let requirements = nextStage.evolutionDetails {
                                Text(requirements.description)
                                    .font(.callout)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private func pokemonView(_ stage: PokemonEvolutionChain.EvolutionStage) -> some View {
        VStack(spacing: 12) {
            if let imageUrl = stage.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    } else {
                        ProgressView()
                            .frame(width: 120, height: 120)
                    }
                }
            } else {
                // Default image if URL is nil
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 4) {
                Text(stage.pokemonName)
                    .font(.title3)
                    .fontWeight(.bold)
                
                if let id = stage.pokemonId {
                    Text("#\(id)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .onTapGesture {
            if let id = stage.pokemonId {
                onPokemonSelected?(id)
            }
        }
    }
}

// MARK: - Preview
struct EvolutionChainView_Previews: PreviewProvider {
    static var previews: some View {
        let bulbasaurStage = PokemonEvolutionChain.EvolutionStage(
            id: "bulbasaur",
            pokemonName: "Bulbasaur",
            pokemonId: 1,
            imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
            evolutionDetails: nil,
            evolvesTo: []
        )
        
        let ivysaurStage = PokemonEvolutionChain.EvolutionStage(
            id: "ivysaur",
            pokemonName: "Ivysaur",
            pokemonId: 2,
            imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png",
            evolutionDetails: PokemonEvolutionChain.EvolutionStage.EvolutionRequirements(
                levelRequired: 16,
                happiness: nil,
                item: nil,
                condition: nil
            ),
            evolvesTo: []
        )
        
        let venusaurStage = PokemonEvolutionChain.EvolutionStage(
            id: "venusaur",
            pokemonName: "Venusaur",
            pokemonId: 3,
            imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png",
            evolutionDetails: PokemonEvolutionChain.EvolutionStage.EvolutionRequirements(
                levelRequired: 32,
                happiness: nil,
                item: nil,
                condition: nil
            ),
            evolvesTo: []
        )
        
        // Create a mock chain where bulbasaur evolves to ivysaur, which evolves to venusaur
        var bulbasaurWithEvolutions = bulbasaurStage
        var ivysaurWithEvolutions = ivysaurStage
        ivysaurWithEvolutions.evolvesTo = [venusaurStage]
        bulbasaurWithEvolutions.evolvesTo = [ivysaurWithEvolutions]
        
        let mockChain = PokemonEvolutionChain(
            chainId: 1,
            evolutionStages: [bulbasaurWithEvolutions]
        )
        
        return Group {
            EvolutionChainView(evolutionChain: mockChain) { id in
                print("Selected Pokemon with ID: \(id)")
            }
            .padding()
            .previewDisplayName("Horizontal Evolution Chain")
            
            DetailedEvolutionPathView(
                stages: [bulbasaurStage, ivysaurStage, venusaurStage]
            ) { id in
                print("Selected Pokemon with ID: \(id)")
            }
            .padding()
            .previewDisplayName("Detailed Evolution Path")
        }
    }
} 