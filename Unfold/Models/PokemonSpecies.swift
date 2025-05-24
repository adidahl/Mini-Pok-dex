import Foundation

struct PokemonSpecies: Codable {
    let id: Int
    let name: String
    let evolutionChain: EvolutionChainURL
    let flavorTextEntries: [FlavorTextEntry]
    let genera: [Genus]
    let generation: Generation
    let growthRate: GrowthRate
    let habitat: Habitat?
    let hasGenderDifferences: Bool
    let isBaby: Bool
    let isLegendary: Bool
    let isMythical: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, genera, generation, habitat
        case evolutionChain = "evolution_chain"
        case flavorTextEntries = "flavor_text_entries"
        case growthRate = "growth_rate"
        case hasGenderDifferences = "has_gender_differences"
        case isBaby = "is_baby"
        case isLegendary = "is_legendary"
        case isMythical = "is_mythical"
    }
    
    struct EvolutionChainURL: Codable {
        let url: String
        
        // Extract the evolution chain ID from the URL
        var id: Int? {
            let components = url.split(separator: "/")
            return components.last.flatMap { Int($0) }
        }
    }
    
    struct FlavorTextEntry: Codable {
        let flavorText: String
        let language: Language
        let version: Version
        
        enum CodingKeys: String, CodingKey {
            case flavorText = "flavor_text"
            case language, version
        }
        
        struct Language: Codable {
            let name: String
            let url: String
        }
        
        struct Version: Codable {
            let name: String
            let url: String
        }
    }
    
    struct Genus: Codable {
        let genus: String
        let language: Language
        
        struct Language: Codable {
            let name: String
            let url: String
        }
    }
    
    struct Generation: Codable {
        let name: String
        let url: String
    }
    
    struct GrowthRate: Codable {
        let name: String
        let url: String
    }
    
    struct Habitat: Codable {
        let name: String
        let url: String
    }
    
    // Helper methods
    var englishDescription: String {
        let englishEntries = flavorTextEntries.filter { $0.language.name == "en" }
        // Get the most recent version's description
        return englishEntries.first?.flavorText
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{0C}", with: " ")
            .replacingOccurrences(of: "POKéMON", with: "Pokémon") ?? "No description available."
    }
    
    var category: String {
        let englishGenus = genera.first(where: { $0.language.name == "en" })?.genus ?? "Unknown"
        return englishGenus
    }
} 