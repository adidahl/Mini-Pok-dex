//
//  UnfoldUITests.swift
//  UnfoldUITests
//
//  Created by Adi Dahl on 24/05/2025.
//

import XCTest

final class UnfoldUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // Skip welcome screen if present
        if app.buttons["Get Started"].exists {
            app.buttons["Get Started"].tap()
        }
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testAppLaunches() throws {
        // Simple test to verify the app launches and main UI is present
        XCTAssertTrue(app.tabBars.buttons["Random"].exists, "Random tab should exist")
        XCTAssertTrue(app.tabBars.buttons["Search"].exists, "Search tab should exist")
        XCTAssertTrue(app.tabBars.buttons["Favorites"].exists, "Favorites tab should exist")
    }
    
    @MainActor
    func testRandomPokemonButtonExists() throws {
        // Test that the random Pokemon button exists
        XCTAssertTrue(app.buttons["Get Random Pokémon"].exists || 
                     app.buttons["New Random Pokémon"].exists,
                     "Random Pokemon button should exist")
    }
    
    @MainActor
    func testSearchFieldExists() throws {
        // Go to Search tab
        app.tabBars.buttons["Search"].tap()
        
        // Verify search field exists
        XCTAssertTrue(app.textFields["Search Pokémon"].exists, "Search field should exist")
    }
    
    @MainActor
    func testTabNavigation() throws {
        // Test basic tab navigation
        app.tabBars.buttons["Search"].tap()
        // Instead of checking navigation title, check for search field which is unique to search screen
        XCTAssertTrue(app.textFields["Search Pokémon"].exists, "Should be on Search screen")
        
        app.tabBars.buttons["Favorites"].tap()
        // Check for favorites-specific content
        XCTAssertTrue(app.staticTexts["No Favorites Yet"].exists || app.staticTexts["Favorites"].exists, "Should be on Favorites screen")
        
        app.tabBars.buttons["Random"].tap()
        // Check for random Pokemon button which is unique to random screen
        XCTAssertTrue(app.buttons["Get Random Pokémon"].exists || app.buttons["New Random Pokémon"].exists, "Should be on Random screen")
    }
}
