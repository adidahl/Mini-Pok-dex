import Foundation

// Custom error types for network requests
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int)
    case unknownError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .noData:
            return "No data was received from the server."
        case .decodingError:
            return "Failed to decode the data."
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}

// Network manager for API requests
class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://pokeapi.co/api/v2"
    private let session: URLSession
    
    // Cache to store previous responses
    private var cache = NSCache<NSString, NSData>()
    
    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        session = URLSession(configuration: config)
    }
    
    // MARK: - API Endpoints
    
    enum Endpoint {
        case pokemon(idOrName: String)
        case pokemonList(limit: Int, offset: Int)
        case pokemonSpecies(id: Int)
        case evolutionChain(id: Int)
        case type(idOrName: String)
        
        var path: String {
            switch self {
            case .pokemon(let idOrName):
                return "/pokemon/\(idOrName)"
            case .pokemonList(let limit, let offset):
                return "/pokemon?limit=\(limit)&offset=\(offset)"
            case .pokemonSpecies(let id):
                return "/pokemon-species/\(id)"
            case .evolutionChain(let id):
                return "/evolution-chain/\(id)"
            case .type(let idOrName):
                return "/type/\(idOrName)"
            }
        }
    }
    
    // MARK: - Fetch Methods
    
    /// Fetch data from the PokeAPI
    /// - Parameters:
    ///   - endpoint: The API endpoint to fetch from
    ///   - completion: Completion handler with Result type
    func fetchData<T: Decodable>(from endpoint: Endpoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        let urlString = baseURL + endpoint.path
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Check cache first
        if let cachedData = cache.object(forKey: urlString as NSString) {
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: cachedData as Data)
                completion(.success(decodedData))
                return
            } catch {
                // If decoding fails, continue with the network request
                print("Cache decoding failed: \(error)")
            }
        }
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(.unknownError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noData))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // Cache the response data
            self.cache.setObject(data as NSData, forKey: urlString as NSString)
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Convenience Methods
    
    /// Fetch a specific Pokemon by ID or name
    /// - Parameters:
    ///   - idOrName: The Pokemon ID or name
    ///   - completion: Completion handler with Result type
    func fetchPokemon(idOrName: String, completion: @escaping (Result<Pokemon, NetworkError>) -> Void) {
        fetchData(from: .pokemon(idOrName: idOrName), completion: completion)
    }
    
    /// Fetch a list of Pokemon with pagination
    /// - Parameters:
    ///   - limit: Number of Pokemon to fetch
    ///   - offset: Starting offset for pagination
    ///   - completion: Completion handler with Result type
    func fetchPokemonList(limit: Int = 20, offset: Int = 0, completion: @escaping (Result<PokemonListResponse, NetworkError>) -> Void) {
        fetchData(from: .pokemonList(limit: limit, offset: offset), completion: completion)
    }
    
    /// Fetch Pokemon species data by ID
    /// - Parameters:
    ///   - id: The Pokemon species ID
    ///   - completion: Completion handler with Result type
    func fetchPokemonSpecies(id: Int, completion: @escaping (Result<PokemonSpecies, NetworkError>) -> Void) {
        fetchData(from: .pokemonSpecies(id: id), completion: completion)
    }
    
    /// Fetch evolution chain data by ID
    /// - Parameters:
    ///   - id: The evolution chain ID
    ///   - completion: Completion handler with Result type
    func fetchEvolutionChain(id: Int, completion: @escaping (Result<EvolutionChain, NetworkError>) -> Void) {
        fetchData(from: .evolutionChain(id: id), completion: completion)
    }
    
    /// Fetch a random Pokemon
    /// - Parameter completion: Completion handler with Result type
    func fetchRandomPokemon(completion: @escaping (Result<Pokemon, NetworkError>) -> Void) {
        // Pokémon IDs go up to about 1000 in the API
        let randomId = Int.random(in: 1...898)
        fetchPokemon(idOrName: String(randomId), completion: completion)
    }
    
    /// Fetch Pokemon by type
    /// - Parameters:
    ///   - type: The Pokemon type (e.g. "fire", "water")
    ///   - completion: Completion handler with Result type
    func fetchPokemonByType(type: String, completion: @escaping (Result<[PokemonListItem], NetworkError>) -> Void) {
        // First fetch the type data
        fetchData(from: .type(idOrName: type)) { (result: Result<PokemonTypeResponse, NetworkError>) in
            switch result {
            case .success(let typeResponse):
                // Extract the Pokemon from the type response
                let pokemonList = typeResponse.pokemon.map { $0.pokemon }
                completion(.success(pokemonList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// Additional model needed for type response
struct PokemonTypeResponse: Codable {
    let id: Int
    let name: String
    let pokemon: [PokemonTypeEntry]
    
    struct PokemonTypeEntry: Codable {
        let pokemon: PokemonListItem
        let slot: Int
    }
} 