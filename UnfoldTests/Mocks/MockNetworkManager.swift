import Foundation
@testable import Unfold

class MockNetworkManager {
    // Control mock behavior
    var shouldSucceed = true
    var mockError: NetworkError = .noData
    
    // Mock data
    var mockPokemon: Pokemon?
    var mockPokemonListResponse: PokemonListResponse?
    var mockPokemonSpecies: PokemonSpecies?
    var mockEvolutionChain: PokemonEvolutionChainResponse?
    
    // Keep track of calls made
    var fetchPokemonCalled = false
    var fetchPokemonIdOrName: String?
    var fetchPokemonListCalled = false
    var fetchPokemonSpeciesCalled = false
    var fetchPokemonSpeciesId: Int?
    var fetchEvolutionChainCalled = false
    var fetchEvolutionChainId: Int?
    var fetchRandomPokemonCalled = false
    
    // Reset state for tests
    func reset() {
        shouldSucceed = true
        mockError = .noData
        mockPokemon = nil
        mockPokemonListResponse = nil
        mockPokemonSpecies = nil
        mockEvolutionChain = nil
        
        fetchPokemonCalled = false
        fetchPokemonIdOrName = nil
        fetchPokemonListCalled = false
        fetchPokemonSpeciesCalled = false
        fetchPokemonSpeciesId = nil
        fetchEvolutionChainCalled = false
        fetchEvolutionChainId = nil
        fetchRandomPokemonCalled = false
    }
}

// Extend to conform to NetworkManagerProtocol
extension MockNetworkManager: NetworkManagerProtocol {
    func fetchPokemon(idOrName: String, completion: @escaping (Result<Pokemon, NetworkError>) -> Void) {
        fetchPokemonCalled = true
        fetchPokemonIdOrName = idOrName
        
        if shouldSucceed, let mockPokemon = mockPokemon {
            completion(.success(mockPokemon))
        } else {
            completion(.failure(mockError))
        }
    }
    
    func fetchPokemonList(limit: Int, offset: Int, completion: @escaping (Result<PokemonListResponse, NetworkError>) -> Void) {
        fetchPokemonListCalled = true
        
        if shouldSucceed, let mockResponse = mockPokemonListResponse {
            completion(.success(mockResponse))
        } else {
            completion(.failure(mockError))
        }
    }
    
    func fetchPokemonSpecies(id: Int, completion: @escaping (Result<PokemonSpecies, NetworkError>) -> Void) {
        fetchPokemonSpeciesCalled = true
        fetchPokemonSpeciesId = id
        
        if shouldSucceed, let mockSpecies = mockPokemonSpecies {
            completion(.success(mockSpecies))
        } else {
            completion(.failure(mockError))
        }
    }
    
    func fetchEvolutionChain(id: Int, completion: @escaping (Result<PokemonEvolutionChainResponse, NetworkError>) -> Void) {
        fetchEvolutionChainCalled = true
        fetchEvolutionChainId = id
        
        if shouldSucceed, let mockChain = mockEvolutionChain {
            completion(.success(mockChain))
        } else {
            completion(.failure(mockError))
        }
    }
    
    func fetchRandomPokemon(completion: @escaping (Result<Pokemon, NetworkError>) -> Void) {
        fetchRandomPokemonCalled = true
        
        if shouldSucceed, let mockPokemon = mockPokemon {
            completion(.success(mockPokemon))
        } else {
            completion(.failure(mockError))
        }
    }
} 