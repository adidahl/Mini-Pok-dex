import Foundation

struct Pokemon: Identifiable, Codable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: Sprites
    let types: [PokemonType]
    let stats: [Stat]
    
    struct Sprites: Codable {
        let frontDefault: String
        let other: OtherSprites?
        
        struct OtherSprites: Codable {
            let officialArtwork: OfficialArtwork?
            
            struct OfficialArtwork: Codable {
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
    
    struct PokemonType: Codable {
        let slot: Int
        let type: TypeInfo
        
        struct TypeInfo: Codable {
            let name: String
            let url: String
        }
    }
    
    struct Stat: Codable {
        let baseStat: Int
        let effort: Int
        let stat: StatInfo
        
        struct StatInfo: Codable {
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
struct PokemonListItem: Identifiable, Codable {
    let id: Int
    let name: String
    let url: String
    
    var formattedName: String {
        return name.capitalized
    }
}

// Response structure for the Pokemon list API
struct PokemonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItem]
} 