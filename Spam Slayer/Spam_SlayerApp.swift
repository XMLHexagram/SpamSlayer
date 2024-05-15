//
//  Spam_SlayerApp.swift
//  Spam Slayer
//
//  Created by Hexagram on 2024/5/12.
//

import SwiftUI
import SwiftData
import ThisKit

@main
struct Spam_SlayerApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(TKErrorHandler.default)
        }
//        .modelContainer(sharedModelContainer)
    }
}
