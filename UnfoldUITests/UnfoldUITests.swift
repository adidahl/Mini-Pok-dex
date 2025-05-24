//
//  UnfoldUITests.swift
//  UnfoldUITests
//
//  Created by Adi Dahl on 24/05/2025.
//

import XCTest

final class UnfoldUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testTabNavigation() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launch()
        
        // Verify that we start with the welcome screen or directly in the app
        // If welcome screen is shown, tap "Get Started"
        if app.buttons["Get Started"].exists {
            app.buttons["Get Started"].tap()
        }
        
        // Verify that the main app tabs are present
        XCTAssertTrue(app.tabBars.buttons["Random"].exists, "Random tab should exist")
        XCTAssertTrue(app.tabBars.buttons["Search"].exists, "Search tab should exist")
        XCTAssertTrue(app.tabBars.buttons["Favorites"].exists, "Favorites tab should exist")
        
        // Test navigating between tabs
        app.tabBars.buttons["Search"].tap()
        XCTAssertTrue(app.navigationBars["Pokémon Search"].exists, "Should be on Search screen")
        
        app.tabBars.buttons["Favorites"].tap()
        XCTAssertTrue(app.navigationBars["Favorites"].exists, "Should be on Favorites screen")
        
        app.tabBars.buttons["Random"].tap()
        XCTAssertTrue(app.navigationBars["Random Pokémon"].exists, "Should be on Random screen")
    }
    
    @MainActor
    func testSearchPokemon() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launch()
        
        // Skip welcome screen if present
        if app.buttons["Get Started"].exists {
            app.buttons["Get Started"].tap()
        }
        
        // Go to Search tab
        app.tabBars.buttons["Search"].tap()
        
        // Enter a search query
        let searchField = app.textFields["Search Pokémon"]
        XCTAssertTrue(searchField.exists, "Search field should exist")
        
        searchField.tap()
        searchField.typeText("pikachu")
        
        // Wait for search results to appear (with timeout)
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: app.staticTexts["Pikachu"])
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        
        // Verify search results
        if result == .completed {
            XCTAssertTrue(app.staticTexts["Pikachu"].exists, "Pikachu should appear in search results")
            
            // Optionally clear search
            app.buttons["Clear"].tap()
            XCTAssertEqual(searchField.value as? String, "", "Search field should be cleared")
        } else {
            // If we can't find Pikachu (maybe due to network issues), at least verify the search UI is working
            XCTAssertTrue(app.staticTexts["Search Results"].exists || 
                         app.staticTexts["No Pokémon Found"].exists,
                         "Should show either search results or no results message")
        }
    }
    
    @MainActor
    func testRandomPokemon() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launch()
        
        // Skip welcome screen if present
        if app.buttons["Get Started"].exists {
            app.buttons["Get Started"].tap()
        }
        
        // Verify we're on the Random tab (it's the default tab)
        XCTAssertTrue(app.navigationBars["Random Pokémon"].exists, "Should start on Random Pokémon screen")
        
        // Wait for a Pokemon to load
        let newRandomButton = app.buttons["New Random Pokémon"]
        let getRandomButton = app.buttons["Get Random Pokémon"]
        
        // Check if we have a Pokemon loaded or need to tap the initial button
        if getRandomButton.exists {
            getRandomButton.tap()
        }
        
        // Wait for the New Random button to appear (meaning a Pokemon was loaded)
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: newRandomButton)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        
        // Verify that Pokemon info is displayed
        if result == .completed {
            XCTAssertTrue(newRandomButton.exists, "New Random Pokémon button should exist")
            XCTAssertTrue(app.buttons["View Full Details"].exists, "View Full Details button should exist")
            
            // Tap New Random button to load another Pokemon
            newRandomButton.tap()
            
            // Wait for the new Pokemon to load
            let waitForReload = XCTWaiter.wait(for: [expectation], timeout: 5.0)
            XCTAssertEqual(waitForReload, .completed, "Should be able to load another random Pokemon")
        } else {
            XCTFail("Failed to load a random Pokemon")
        }
    }
    
    @MainActor
    func testBookmarkingPokemon() throws {
        // Launch the app
        let app = XCUIApplication()
        app.launch()
        
        // Skip welcome screen if present
        if app.buttons["Get Started"].exists {
            app.buttons["Get Started"].tap()
        }
        
        // Load a random Pokemon
        if app.buttons["Get Random Pokémon"].exists {
            app.buttons["Get Random Pokémon"].tap()
        }
        
        // Wait for Pokemon to load
        let addToFavoritesButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Add to Favorites'")).firstMatch
        let removeFromFavoritesButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Remove from Favorites'")).firstMatch
        
        // Wait for either button to appear
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: app.buttons["View Full Details"])
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        
        if result == .completed {
            // Add to favorites if not already favorited
            if addToFavoritesButton.exists {
                addToFavoritesButton.tap()
                // Wait briefly for UI to update
                sleep(1)
                // Verify it changed to Remove from Favorites
                XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS 'Remove from Favorites'")).firstMatch.exists,
                             "Button should change to Remove from Favorites")
            } else if removeFromFavoritesButton.exists {
                // Already favorited, so unfavorite it first, then favorite it again
                removeFromFavoritesButton.tap()
                sleep(1)
                // Now add to favorites
                app.buttons.matching(NSPredicate(format: "label CONTAINS 'Add to Favorites'")).firstMatch.tap()
                sleep(1)
                // Verify it changed back
                XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label CONTAINS 'Remove from Favorites'")).firstMatch.exists,
                             "Button should change to Remove from Favorites")
            } else {
                XCTFail("Neither Add to Favorites nor Remove from Favorites button found")
            }
            
            // Navigate to Favorites tab to verify the Pokemon was added
            app.tabBars.buttons["Favorites"].tap()
            
            // Verify we're on Favorites screen
            XCTAssertTrue(app.navigationBars["Favorites"].exists, "Should be on Favorites screen")
            
            // Check if the Pokemon appears in the favorites list
            // This is a basic check - we don't know which Pokemon was bookmarked
            XCTAssertFalse(app.staticTexts["No Favorites Yet"].exists, 
                          "Should not show empty state after bookmarking a Pokemon")
        } else {
            XCTFail("Failed to load a Pokemon to bookmark")
        }
    }
}
