import Foundation

struct Pokemon: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: Sprites
    let types: [PokemonType]
    let stats: [Stat]
    
    // Implement hash(into:) for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Implement == for Hashable conformance
    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
        return lhs.id == rhs.id
    }
    
    struct Sprites: Codable, Hashable {
        let frontDefault: String
        let other: OtherSprites?
        
        struct OtherSprites: Codable, Hashable {
            let officialArtwork: OfficialArtwork?
            
            struct OfficialArtwork: Codable, Hashable {
                let frontDefault: String?
                
                enum CodingKeys: String, CodingKey {
                    case frontDefault = "front_default"
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case officialArtwork = "official-artwork"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
            case other
        }
    }
    
    struct PokemonType: Codable, Hashable {
        let slot: Int
        let type: TypeInfo
        
        struct TypeInfo: Codable, Hashable {
            let name: String
            let url: String
        }
    }
    
    struct Stat: Codable, Hashable {
        let baseStat: Int
        let effort: Int
        let stat: StatInfo
        
        struct StatInfo: Codable, Hashable {
            let name: String
            let url: String
        }
        
        enum CodingKeys: String, CodingKey {
            case baseStat = "base_stat"
            case effort
            case stat
        }
    }
    
    // Helper methods
    var mainImageURL: URL? {
        if let officialArtworkURL = sprites.other?.officialArtwork?.frontDefault {
            return URL(string: officialArtworkURL)
        }
        return URL(string: sprites.frontDefault)
    }
    
    var typeNames: [String] {
        return types.sorted(by: { $0.slot < $1.slot }).map { $0.type.name.capitalized }
    }
    
    func getStatValue(forName name: String) -> Int {
        return stats.first(where: { $0.stat.name == name })?.baseStat ?? 0
    }
}

// This is a more lightweight model used for lists and search results
struct PokemonListItem: Identifiable, Codable, Equatable {
    var id: Int {
        // Extract ID from the URL
        // URL format is typically: "https://pokeapi.co/api/v2/pokemon/25/"
        if let lastPathComponent = URL(string: url)?.lastPathComponent,
           let id = Int(lastPathComponent) {
            return id
        }
        // Fallback if URL parsing fails
        return 0
    }
    
    let name: String
    let url: String
    
    var formattedName: String {
        return name.capitalized
    }
    
    // Implement the Equatable protocol
    static func == (lhs: PokemonListItem, rhs: PokemonListItem) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    enum CodingKeys: String, CodingKey {
        case name, url
    }
}

// Response structure for the Pokemon list API
struct PokemonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItem]
} 