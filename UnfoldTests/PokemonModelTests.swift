import XCTest
@testable import Unfold

final class PokemonModelTests: XCTestCase {
    
    // MARK: - PokemonListItem Tests
    
    func testPokemonListItemIdExtraction() {
        // Test various URL formats to ensure ID is correctly extracted
        
        // Standard URL format
        let pokemon1 = PokemonListItem(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
        XCTAssertEqual(pokemon1.id, 1, "ID should be 1 for Bulbasaur")
        
        // URL with no trailing slash
        let pokemon2 = PokemonListItem(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2")
        XCTAssertEqual(pokemon2.id, 2, "ID should be 2 for Ivysaur")
        
        // URL with query parameters
        let pokemon3 = PokemonListItem(name: "venusaur", url: "https://pokeapi.co/api/v2/pokemon/3/?language=en")
        XCTAssertEqual(pokemon3.id, 3, "ID should be 3 for Venusaur")
        
        // URL with different domain
        let pokemon4 = PokemonListItem(name: "charmander", url: "https://example.com/api/v2/pokemon/4/")
        XCTAssertEqual(pokemon4.id, 4, "ID should be 4 for Charmander")
        
        // URL with non-numeric ID should default to 0
        let pokemonInvalid = PokemonListItem(name: "invalid", url: "https://pokeapi.co/api/v2/pokemon/invalid/")
        XCTAssertEqual(pokemonInvalid.id, 0, "ID should be 0 for invalid URL")
    }
    
    func testPokemonListItemFormattedName() {
        // Test that names are properly formatted
        
        // Simple name
        let pokemon1 = PokemonListItem(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
        XCTAssertEqual(pokemon1.formattedName, "Bulbasaur", "Name should be capitalized")
        
        // Hyphenated name
        let pokemon2 = PokemonListItem(name: "tapu-koko", url: "https://pokeapi.co/api/v2/pokemon/785/")
        XCTAssertEqual(pokemon2.formattedName, "Tapu Koko", "Hyphens should be replaced with spaces and capitalized")
        
        // Name with multiple hyphens
        let pokemon3 = PokemonListItem(name: "type-null", url: "https://pokeapi.co/api/v2/pokemon/772/")
        XCTAssertEqual(pokemon3.formattedName, "Type Null", "Hyphens should be replaced with spaces and capitalized")
    }
    
    // MARK: - Pokemon Tests
    
    func testPokemonGetStatValue() {
        // Create a Pokemon with stats
        let pokemon = Pokemon(
            id: 1,
            name: "bulbasaur",
            height: 7,
            weight: 69,
            sprites: Pokemon.Sprites(
                frontDefault: "https://example.com/bulbasaur.png",
                other: Pokemon.Sprites.OtherSprites(
                    officialArtwork: Pokemon.Sprites.OtherSprites.OfficialArtwork(
                        frontDefault: "https://example.com/bulbasaur-official.png"
                    )
                )
            ),
            types: [],
            stats: [
                Pokemon.Stat(
                    baseStat: 45,
                    effort: 0,
                    stat: Pokemon.Stat.StatInfo(
                        name: "hp",
                        url: "https://example.com/hp"
                    )
                ),
                Pokemon.Stat(
                    baseStat: 49,
                    effort: 0,
                    stat: Pokemon.Stat.StatInfo(
                        name: "attack",
                        url: "https://example.com/attack"
                    )
                ),
                Pokemon.Stat(
                    baseStat: 65,
                    effort: 0,
                    stat: Pokemon.Stat.StatInfo(
                        name: "defense",
                        url: "https://example.com/defense"
                    )
                )
            ]
        )
        
        // Test finding existing stats
        XCTAssertEqual(pokemon.getStatValue(forName: "hp"), 45, "HP stat should be 45")
        XCTAssertEqual(pokemon.getStatValue(forName: "attack"), 49, "Attack stat should be 49")
        XCTAssertEqual(pokemon.getStatValue(forName: "defense"), 65, "Defense stat should be 65")
        
        // Test stat that doesn't exist
        XCTAssertEqual(pokemon.getStatValue(forName: "speed"), 0, "Non-existent stat should return 0")
    }
    
    func testPokemonMainImageURL() {
        // Create a Pokemon with sprites
        let pokemon = Pokemon(
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
            types: [],
            stats: []
        )
        
        // Test that mainImageURL returns the official artwork
        XCTAssertEqual(
            pokemon.mainImageURL?.absoluteString,
            "https://example.com/pikachu-official.png",
            "Main image URL should be the official artwork"
        )
    }
} 