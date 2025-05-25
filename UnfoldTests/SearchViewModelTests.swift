//
//  SearchViewModelTests.swift
//  UnfoldTests
//
//  Created by Adi Dahl on 24/05/2025.
//

import XCTest
@testable import Unfold

final class SearchViewModelTests: XCTestCase {
    
    var viewModel: SearchViewModel!
    
    override func setUpWithError() throws {
        viewModel = SearchViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func testClearSearch() throws {
        // Test that clearing search resets the results
        viewModel.clearSearch()
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }
    
    func testSimilarityCalculation() throws {
        // Test the similarity calculation method
        let similarity = viewModel.calculateSimilarity(between: "pikachu", and: "pika")
        XCTAssertGreaterThan(similarity, 0.0, "Similarity should be greater than 0")
        XCTAssertLessThanOrEqual(similarity, 1.0, "Similarity should be less than or equal to 1")
    }

} 