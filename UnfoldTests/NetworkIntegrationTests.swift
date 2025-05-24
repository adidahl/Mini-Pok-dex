import XCTest
@testable import Unfold

final class NetworkIntegrationTests: XCTestCase {
    
    var mockNetworkManager: MockNetworkManager!
    var viewModel: PokemonViewModel!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        viewModel = PokemonViewModel()
        
        // Create a mock Pokemon for testing
        mockNetworkManager.mockPokemon = createMockPokemon()
        
        // Create mock species data
        mockNetworkManager.mockPokemonSpecies = createMockPokemonSpecies()
        
        // Create mock evolution chain
        mockNetworkManager.mockEvolutionChain = createMockEvolutionChain()
    }
    
    override func tearDown() {
        mockNetworkManager = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - PokemonViewModel Tests
    
    func testFetchPokemon() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch Pokemon")
        let pokemonId = "25" // Pikachu
        
        // Configure the network manager to use our mock
        NetworkManager.shared = mockNetworkManager
        
        // When
        viewModel.fetchPokemon(idOrName: pokemonId)
        
        // Delay to allow async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        // Verify network manager was called correctly
        XCTAssertTrue(mockNetworkManager.fetchPokemonCalled, "fetchPokemon should be called")
        XCTAssertEqual(mockNetworkManager.fetchPokemonIdOrName, pokemonId, "Should fetch Pikachu")
        
        // Verify view model was updated
        XCTAssertEqual(viewModel.pokemon?.id, 25, "Pokemon ID should be 25")
        XCTAssertEqual(viewModel.pokemon?.name, "pikachu", "Pokemon name should be pikachu")
        
        // Since the fetch should then get species data, verify that was called too
        XCTAssertTrue(mockNetworkManager.fetchPokemonSpeciesCalled, "fetchPokemonSpecies should be called")
    }
    
    func testFetchPokemonWithError() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch Pokemon with error")
        let pokemonId = "invalid"
        
        // Configure mock to fail
        mockNetworkManager.shouldSucceed = false
        mockNetworkManager.mockError = .invalidResponse
        
        // Configure the network manager to use our mock
        NetworkManager.shared = mockNetworkManager
        
        // When
        viewModel.fetchPokemon(idOrName: pokemonId)
        
        // Delay to allow async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        // Verify error state
        switch viewModel.state {
        case .error(let error):
            // Check if it's a NetworkError
            if let networkError = error as? NetworkError {
                XCTAssertEqual(networkError, .invalidResponse, "Error should be invalidResponse")
            } else {
                XCTFail("Error should be a NetworkError")
            }
        default:
            XCTFail("State should be error")
        }
    }
    
    func testFetchRandomPokemon() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch random Pokemon")
        
        // Configure the network manager to use our mock
        NetworkManager.shared = mockNetworkManager
        
        // When
        viewModel.fetchRandomPokemon()
        
        // Delay to allow async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        // Verify network manager was called correctly
        XCTAssertTrue(mockNetworkManager.fetchRandomPokemonCalled, "fetchRandomPokemon should be called")
        
        // Verify view model was updated
        XCTAssertNotNil(viewModel.pokemon, "Pokemon should not be nil")
        
        // Since the fetch should then get species data, verify that was called too
        XCTAssertTrue(mockNetworkManager.fetchPokemonSpeciesCalled, "fetchPokemonSpecies should be called")
    }
    
    // MARK: - Helper Methods
    
    private func createMockPokemon() -> Pokemon {
        return Pokemon(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            sprites: Pokemon.Sprites(
                frontDefault: "https://example.com/pikachu.png",
                other: Pokemon.Sprites.OtherSprites(
                    officialArtwork: Pokemon.Sprites.OtherSprites.OfficialArtwork(
                        frontDefault: "https://example.com/pikachu-official.png"
                    )
                )
            ),
            types: [
                Pokemon.PokemonType(
                    slot: 1,
                    type: Pokemon.PokemonType.TypeInfo(
                        name: "electric",
                        url: "https://example.com/electric"
                    )
                )
            ],
            stats: [
                Pokemon.Stat(
                    baseStat: 35,
                    effort: 0,
                    stat: Pokemon.Stat.StatInfo(
                        name: "hp",
                        url: "https://example.com/hp"
                    )
                )
            ]
        )
    }
    
    private func createMockPokemonSpecies() -> PokemonSpecies {
        return PokemonSpecies(
            id: 25,
            name: "pikachu",
            isLegendary: false,
            isMythical: false,
            evolutionChain: PokemonSpecies.EvolutionChainLink(url: "https://example.com/evolution-chain/10"),
            flavorTextEntries: [
                PokemonSpecies.FlavorTextEntry(
                    flavorText: "This is a test description for Pikachu.",
                    language: PokemonSpecies.Language(name: "en", url: ""),
                    version: PokemonSpecies.Version(name: "test", url: "")
                )
            ],
            genera: [
                PokemonSpecies.Genus(
                    genus: "Mouse Pokémon",
                    language: PokemonSpecies.Language(name: "en", url: "")
                )
            ]
        )
    }
    
    private func createMockEvolutionChain() -> PokemonEvolutionChainResponse {
        // Create a simple Pichu -> Pikachu -> Raichu evolution chain
        return PokemonEvolutionChainResponse(
            id: 10,
            chain: PokemonEvolutionChainResponse.Chain(
                species: PokemonEvolutionChainResponse.Species(
                    name: "pichu",
                    url: "https://pokeapi.co/api/v2/pokemon-species/172/"
                ),
                evolves_to: [
                    PokemonEvolutionChainResponse.Chain(
                        species: PokemonEvolutionChainResponse.Species(
                            name: "pikachu",
                            url: "https://pokeapi.co/api/v2/pokemon-species/25/"
                        ),
                        evolves_to: [
                            PokemonEvolutionChainResponse.Chain(
                                species: PokemonEvolutionChainResponse.Species(
                                    name: "raichu",
                                    url: "https://pokeapi.co/api/v2/pokemon-species/26/"
                                ),
                                evolves_to: []
                            )
                        ]
                    )
                ]
            )
        )
    }
} 