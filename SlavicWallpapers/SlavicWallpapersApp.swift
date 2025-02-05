//
//  SlavicWallpapersApp.swift
//  SlavicWallpapers
//
//  Created by Василий Буланов on 04.02.2025.
//

import SwiftUI
import SwiftData

@main
struct SlavicWallpapersApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .modelContainer(sharedModelContainer)
    }
}
