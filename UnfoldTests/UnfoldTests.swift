//
//  UnfoldTests.swift
//  UnfoldTests
//
//  Created by Adi Dahl on 24/05/2025.
//

import Testing
@testable import Unfold

struct UnfoldTests {

    @Test func pokemonModelBasics() async throws {
        // Simple test to verify Pokemon model works
        let pokemon = Pokemon(
            id: 1,
            name: "bulbasaur",
            height: 7,
            weight: 69,
            sprites: Pokemon.Sprites(
                frontDefault: "https://example.com/sprite.png",
                other: nil
            ),
            types: [
                Pokemon.PokemonType(
                    slot: 1,
                    type: Pokemon.PokemonType.TypeInfo(name: "grass", url: "https://example.com/grass")
                )
            ],
            stats: [
                Pokemon.Stat(
                    baseStat: 45,
                    effort: 0,
                    stat: Pokemon.Stat.StatInfo(name: "hp", url: "https://example.com/hp")
                )
            ]
        )
        
        #expect(pokemon.id == 1)
        #expect(pokemon.name == "bulbasaur")
        #expect(pokemon.types.count == 1)
        #expect(pokemon.types.first?.type.name == "grass")
    }

}
