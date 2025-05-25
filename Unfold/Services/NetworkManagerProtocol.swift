import Foundation

// Protocol that defines the network interface
protocol NetworkManagerProtocol {
    func fetchPokemon(idOrName: String, completion: @escaping (Result<Pokemon, NetworkError>) -> Void)
    func fetchPokemonList(limit: Int, offset: Int, completion: @escaping (Result<PokemonListResponse, NetworkError>) -> Void)
    func fetchPokemonSpecies(id: Int, completion: @escaping (Result<PokemonSpecies, NetworkError>) -> Void)
    func fetchEvolutionChain(id: Int, completion: @escaping (Result<EvolutionChain, NetworkError>) -> Void)
    func fetchRandomPokemon(completion: @escaping (Result<Pokemon, NetworkError>) -> Void)
}