//
//  WoDMasterApp.swift
//  WoDMaster
//
//  Created by 张天行 on 2026/3/2.
//

import SwiftUI
import SwiftData

@main
struct WoDMasterApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WOD.self,
            WODMovement.self,
            MovementLibraryItem.self,
            PersonalRecord.self,
            WorkoutResult.self,
            RoundSplit.self,
            UserProfile.self,
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
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
