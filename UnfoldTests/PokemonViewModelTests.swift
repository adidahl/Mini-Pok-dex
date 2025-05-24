import XCTest
@testable import Unfold

final class PokemonViewModelTests: XCTestCase {
    
    var viewModel: PokemonViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = PokemonViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Bookmark Tests
    
    func testToggleBookmark() {
        // Given
        let pokemonId = 25 // Pikachu
        
        // When: Add to bookmarks
        viewModel.toggleBookmark(for: pokemonId)
        
        // Then: Should be bookmarked
        XCTAssertTrue(viewModel.isBookmarked(pokemonId), "Pokemon should be bookmarked after toggling")
        
        // When: Remove from bookmarks
        viewModel.toggleBookmark(for: pokemonId)
        
        // Then: Should not be bookmarked
        XCTAssertFalse(viewModel.isBookmarked(pokemonId), "Pokemon should not be bookmarked after toggling again")
    }
    
    func testIsBookmarked() {
        // Given
        let pokemonId = 1 // Bulbasaur
        
        // When/Then: Initially not bookmarked
        XCTAssertFalse(viewModel.isBookmarked(pokemonId), "Pokemon should not be bookmarked initially")
        
        // When: Add to bookmarks
        viewModel.bookmarkedPokemon.append(pokemonId)
        
        // Then: Should be bookmarked
        XCTAssertTrue(viewModel.isBookmarked(pokemonId), "Pokemon should be bookmarked after adding to bookmarks")
    }
    
    func testLoadBookmarkedPokemon() {
        // Given
        let pokemonIds = [1, 4, 7] // Bulbasaur, Charmander, Squirtle
        UserDefaults.standard.set(pokemonIds, forKey: "bookmarkedPokemon")
        
        // When
        viewModel.loadBookmarkedPokemon()
        
        // Need to wait for the async call to complete
        let expectation = XCTestExpectation(description: "Load bookmarked Pokemon")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(viewModel.bookmarkedPokemon.count, 3, "Should have 3 bookmarked Pokemon")
        XCTAssertTrue(viewModel.bookmarkedPokemon.contains(1), "Bookmarks should contain Bulbasaur")
        XCTAssertTrue(viewModel.bookmarkedPokemon.contains(4), "Bookmarks should contain Charmander")
        XCTAssertTrue(viewModel.bookmarkedPokemon.contains(7), "Bookmarks should contain Squirtle")
    }
    
    // MARK: - State Tests
    
    func testInitialState() {
        // When initialized
        
        // Then
        XCTAssertEqual(viewModel.state, .empty, "Initial state should be empty")
        XCTAssertNil(viewModel.pokemon, "Pokemon should be nil initially")
        XCTAssertNil(viewModel.species, "Species should be nil initially")
        XCTAssertNil(viewModel.evolutionChain, "Evolution chain should be nil initially")
    }
    
    func testReset() {
        // Given: Set up some state
        viewModel.pokemon = createMockPokemon()
        viewModel.state = .loaded
        
        // When
        viewModel.reset()
        
        // Then
        XCTAssertEqual(viewModel.state, .empty, "State should be reset to empty")
        XCTAssertNil(viewModel.pokemon, "Pokemon should be nil after reset")
        XCTAssertNil(viewModel.species, "Species should be nil after reset")
        XCTAssertNil(viewModel.evolutionChain, "Evolution chain should be nil after reset")
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
} 