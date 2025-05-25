//
//  UnfoldApp.swift
//  Unfold
//
//  Created by Adi Dahl on 24/05/2025.
//

import SwiftUI
import SwiftData
import UIKit

// Orientation lock for the app
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait // Lock to portrait orientation
    }
}

@main
struct UnfoldApp: App {
    // Register the app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
