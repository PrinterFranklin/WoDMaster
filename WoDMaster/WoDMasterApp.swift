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
    
    /// Current schema version. Increment this when making breaking schema changes.
    /// This will trigger a full data reset on next launch.
    static let schemaVersion = 2 // v2: Lift/Gym/Cardio categories + tags + isBenchmark
    private static let schemaVersionKey = "WoDMaster.SchemaVersion"
    
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

        // Check if schema version changed — if so, delete old store
        let savedVersion = UserDefaults.standard.integer(forKey: schemaVersionKey)
        if savedVersion != 0 && savedVersion < schemaVersion {
            print("🔄 [Schema] Version changed from \(savedVersion) to \(schemaVersion). Resetting data store...")
            let url = modelConfiguration.url
            let fileManager = FileManager.default
            // SwiftData store files (main + WAL + SHM)
            let storeFiles = [url, url.appendingPathExtension("wal"), url.appendingPathExtension("shm")]
            for file in storeFiles {
                try? fileManager.removeItem(at: file)
            }
        }
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            UserDefaults.standard.set(schemaVersion, forKey: schemaVersionKey)
            return container
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
