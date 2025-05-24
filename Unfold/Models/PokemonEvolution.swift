import Foundation

// Model representing the evolution chain response from PokeAPI
struct EvolutionChain: Codable {
    let id: Int
    let chain: ChainLink
    
    // A recursive structure representing each link in the evolution chain
    struct ChainLink: Codable {
        let species: Species
        let evolutionDetails: [EvolutionDetail]?
        let evolvesTo: [ChainLink]
        
        enum CodingKeys: String, CodingKey {
            case species
            case evolutionDetails = "evolution_details"
            case evolvesTo = "evolves_to"
        }
        
        struct Species: Codable {
            let name: String
            let url: String
        }
        
        struct EvolutionDetail: Codable {
            let minLevel: Int?
            let trigger: Trigger?
            let item: Item?
            let timeOfDay: String?
            let minHappiness: Int?
            let minAffection: Int?
            let minBeauty: Int?
            
            enum CodingKeys: String, CodingKey {
                case minLevel = "min_level"
                case trigger
                case item
                case timeOfDay = "time_of_day"
                case minHappiness = "min_happiness"
                case minAffection = "min_affection"
                case minBeauty = "min_beauty"
            }
            
            struct Trigger: Codable {
                let name: String
                let url: String
            }
            
            struct Item: Codable {
                let name: String
                let url: String
            }
        }
    }
}

// A simplified representation of the evolution chain for the UI
struct PokemonEvolutionChain {
    let chainId: Int
    let evolutionStages: [EvolutionStage]
    
    struct EvolutionStage: Identifiable {
        let id: String // Using the Pokemon name as the ID
        let pokemonName: String
        let pokemonId: Int?
        let imageUrl: String?
        let evolutionDetails: EvolutionRequirements?
        let evolvesTo: [EvolutionStage]
        
        struct EvolutionRequirements {
            let levelRequired: Int?
            let happiness: Int?
            let item: String?
            let condition: String?
            
            // A user-friendly description of evolution requirements
            var description: String {
                var requirements: [String] = []
                
                if let level = levelRequired {
                    requirements.append("Level \(level)")
                }
                
                if let happiness = happiness {
                    requirements.append("Happiness \(happiness)")
                }
                
                if let item = item {
                    requirements.append("Use \(item.capitalized)")
                }
                
                if let condition = condition, !condition.isEmpty {
                    requirements.append(condition)
                }
                
                return requirements.isEmpty ? "No special requirements" : requirements.joined(separator: ", ")
            }
        }
    }
    
    // Convert the API evolution chain to our simplified version
    static func fromAPIResponse(_ response: EvolutionChain) -> PokemonEvolutionChain {
        let stages = parseEvolutionStages(response.chain)
        return PokemonEvolutionChain(chainId: response.id, evolutionStages: stages)
    }
    
    // Recursively parse the evolution chain
    private static func parseEvolutionStages(_ chainLink: EvolutionChain.ChainLink) -> [EvolutionStage] {
        let species = chainLink.species
        let pokemonIdFromUrl = extractPokemonId(from: species.url)
        
        let currentStage = EvolutionStage(
            id: species.name,
            pokemonName: species.name.capitalized,
            pokemonId: pokemonIdFromUrl,
            imageUrl: nil, // Will be populated later from Pokemon details
            evolutionDetails: parseEvolutionDetails(chainLink.evolutionDetails?.first),
            evolvesTo: []
        )
        
        if chainLink.evolvesTo.isEmpty {
            return [currentStage]
        }
        
        // Process each evolution branch
        var result: [EvolutionStage] = []
        for nextLink in chainLink.evolvesTo {
            let nextStages = parseEvolutionStages(nextLink)
            var modifiedCurrentStage = currentStage
            modifiedCurrentStage.evolvesTo.append(contentsOf: nextStages)
            result.append(modifiedCurrentStage)
        }
        
        return result.isEmpty ? [currentStage] : result
    }
    
    // Parse evolution details into a more usable format
    private static func parseEvolutionDetails(_ details: EvolutionChain.ChainLink.EvolutionDetail?) -> EvolutionStage.EvolutionRequirements? {
        guard let details = details else { return nil }
        
        var condition: String?
        if let timeOfDay = details.timeOfDay, !timeOfDay.isEmpty {
            condition = "During \(timeOfDay)"
        }
        
        return EvolutionStage.EvolutionRequirements(
            levelRequired: details.minLevel,
            happiness: details.minHappiness,
            item: details.item?.name,
            condition: condition
        )
    }
    
    // Extract Pokemon ID from the species URL
    private static func extractPokemonId(from url: String) -> Int? {
        // URL format is typically: "https://pokeapi.co/api/v2/pokemon-species/25/"
        let components = url.split(separator: "/")
        if let lastNumberString = components.last(where: { $0.allSatisfy({ $0.isNumber }) }) {
            return Int(lastNumberString)
        }
        return nil
    }
} 