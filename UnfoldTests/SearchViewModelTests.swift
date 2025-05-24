import XCTest
@testable import Unfold

final class SearchViewModelTests: XCTestCase {
    
    var viewModel: SearchViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = SearchViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Search Tests
    
    func testClearSearch() {
        // Given: Set up search state
        viewModel.searchResults = [createMockPokemonListItem()]
        viewModel.isLoading = true
        viewModel.error = NetworkError.noData
        
        // When
        viewModel.clearSearch()
        
        // Then
        XCTAssertTrue(viewModel.searchResults.isEmpty, "Search results should be empty after clearing")
        XCTAssertTrue(viewModel.suggestedResults.isEmpty, "Suggested results should be empty after clearing")
        XCTAssertFalse(viewModel.isLoading, "Loading state should be false after clearing")
        XCTAssertNil(viewModel.error, "Error should be nil after clearing")
    }
    
    func testCalculateSimilarity() {
        // This test verifies the fuzzy matching algorithm
        
        // Test for exact match
        let exactMatch = viewModel.calculateSimilarity(between: "pikachu", and: "pikachu")
        XCTAssertEqual(exactMatch, 1.0, accuracy: 0.001, "Exact match should have similarity of 1.0")
        
        // Test for close match
        let closeMatch = viewModel.calculateSimilarity(between: "pikachu", and: "pikacu")
        XCTAssertGreaterThan(closeMatch, 0.8, "Close match should have high similarity")
        
        // Test for partial match
        let partialMatch = viewModel.calculateSimilarity(between: "pikachu", and: "pika")
        XCTAssertGreaterThan(partialMatch, 0.6, "Partial match should have medium similarity")
        
        // Test for low match
        let lowMatch = viewModel.calculateSimilarity(between: "pikachu", and: "charizard")
        XCTAssertLessThan(lowMatch, 0.5, "Different words should have low similarity")
    }
    
    func testAddToRecentSearches() {
        // Given
        let pokemon = createMockPokemonListItem()
        
        // When
        viewModel.addToRecentSearches(pokemon)
        
        // Then
        XCTAssertEqual(viewModel.recentSearches.count, 1, "Should have 1 recent search")
        XCTAssertEqual(viewModel.recentSearches.first?.id, pokemon.id, "Recent search should match added Pokemon")
        
        // When: Add a different Pokemon
        let anotherPokemon = createMockPokemonListItem(id: 4, name: "charmander")
        viewModel.addToRecentSearches(anotherPokemon)
        
        // Then
        XCTAssertEqual(viewModel.recentSearches.count, 2, "Should have 2 recent searches")
        XCTAssertEqual(viewModel.recentSearches.first?.id, anotherPokemon.id, "Most recent search should be first")
        
        // When: Add the same Pokemon again
        viewModel.addToRecentSearches(anotherPokemon)
        
        // Then: It should not be duplicated
        XCTAssertEqual(viewModel.recentSearches.count, 2, "Should still have 2 recent searches, no duplicates")
        XCTAssertEqual(viewModel.recentSearches.first?.id, anotherPokemon.id, "Most recent search should be first")
    }
    
    // MARK: - Helper Methods
    
    private func createMockPokemonListItem(id: Int = 25, name: String = "pikachu") -> PokemonListItem {
        return PokemonListItem(name: name, url: "https://pokeapi.co/api/v2/pokemon/\(id)/")
    }
} 