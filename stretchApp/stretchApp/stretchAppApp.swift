//
//  stretchAppApp.swift
//  stretchApp
//
//  Created by Abdalla Abdelmagid on 8/9/25.
//

import SwiftUI
import SwiftData

@main
struct stretchAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            StretchCategory.self,
            StretchExercise.self,
            StretchSession.self,
            UserPreferences.self
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
