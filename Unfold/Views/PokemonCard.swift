import SwiftUI

struct PokemonCard: View {
    let pokemon: Pokemon
    var showDetails: Bool = false
    var onTap: (() -> Void)? = nil
    
    // Type colors for background styling
    private let typeColors: [String: Color] = [
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
    
    var body: some View {
        ZStack {
            // Card background with type-based gradient
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        backgroundColor.opacity(0.8),
                        backgroundColor.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            
            // Card content
            VStack(spacing: 12) {
                // Pokemon image
                AsyncImage(url: pokemon.mainImageURL) { phase in
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
                .padding(.top, 8)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 130, height: 130)
                )
                
                // Pokemon ID and name
                VStack(spacing: 4) {
                    Text("#\(pokemon.id)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(pokemon.name.capitalized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                // Pokemon types
                HStack(spacing: 8) {
                    ForEach(pokemon.typeNames, id: \.self) { typeName in
                        Text(typeName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.3))
                            )
                            .foregroundColor(.white)
                    }
                }
                
                if showDetails {
                    // Basic stats (only shown when showDetails is true)
                    VStack(spacing: 4) {
                        HStack {
                            Text("Height:")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("\(Double(pokemon.height) / 10) m")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Weight:")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("\(Double(pokemon.weight) / 10) kg")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Base HP:")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("\(pokemon.getStatValue(forName: "hp"))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.2))
                    )
                    .padding(.top, 4)
                }
            }
            .padding()
        }
        .aspectRatio(2/3, contentMode: .fit)
        .onTapGesture {
            onTap?()
        }
    }
    
    // Compute background color based on Pokemon's primary type
    private var backgroundColor: Color {
        if let primaryType = pokemon.typeNames.first?.lowercased() {
            return typeColors[primaryType] ?? Color(.systemGray)
        }
        return Color(.systemGray)
    }
}

// Preview provider for SwiftUI canvas
struct PokemonCard_Previews: PreviewProvider {
    static var previews: some View {
        // Sample Pokemon for preview
        let samplePokemon = Pokemon(
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
                )
            ]
        )
        
        Group {
            PokemonCard(pokemon: samplePokemon)
                .frame(width: 200)
                .previewDisplayName("Basic Card")
            
            PokemonCard(pokemon: samplePokemon, showDetails: true)
                .frame(width: 200)
                .previewDisplayName("Card with Details")
        }
    }
} 