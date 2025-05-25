//
//  PokemonViewModelTests.swift
//  UnfoldTests
//
//  Created by Adi Dahl on 24/05/2025.
//

import XCTest
@testable import Unfold

final class PokemonViewModelTests: XCTestCase {
    
    var viewModel: PokemonViewModel!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUpWithError() throws {
        mockNetworkManager = MockNetworkManager()
        viewModel = PokemonViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockNetworkManager = nil
    }
    
    func testInitialState() throws {
        // Test that view model starts in correct initial state
        XCTAssertNil(viewModel.pokemon)
        XCTAssertEqual(viewModel.state, .empty)
        XCTAssertNil(viewModel.species)
    }
} 