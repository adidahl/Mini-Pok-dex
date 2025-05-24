//
//  UnfoldApp.swift
//  Unfold
//
//  Created by Adi Dahl on 24/05/2025.
//

import SwiftUI
import SwiftData

@main
struct UnfoldApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // Apply the welcome screen to the main tab view
            MainTabView()
                .withWelcomeScreen()
                .preferredColorScheme(.light) // Default to light mode
        }
        .modelContainer(sharedModelContainer)
    }
}
