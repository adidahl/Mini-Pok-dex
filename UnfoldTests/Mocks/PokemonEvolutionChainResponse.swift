import Foundation
@testable import Unfold

// This model represents a simplified version of the EvolutionChain 
// specifically for testing purposes
struct PokemonEvolutionChainResponse: Codable {
    let id: Int
    let chain: Chain
    
    struct Chain: Codable {
        let species: Species
        let evolves_to: [Chain]
        
        struct Species: Codable {
            let name: String
            let url: String
        }
    }
    
    // Convert to the app's EvolutionChain model if needed
    func toEvolutionChain() -> EvolutionChain {
        return EvolutionChain(
            id: id,
            chain: convertChain(chain)
        )
    }
    
    private func convertChain(_ testChain: Chain) -> EvolutionChain.ChainLink {
        return EvolutionChain.ChainLink(
            species: EvolutionChain.ChainLink.Species(
                name: testChain.species.name,
                url: testChain.species.url
            ),
            evolutionDetails: nil,
            evolvesTo: testChain.evolves_to.map { convertChain($0) }
        )
    }
} 