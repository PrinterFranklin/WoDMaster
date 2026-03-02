//
//  DataSeeder.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation
import SwiftData

struct DataSeeder {
    
    /// Seed benchmark WODs from JSON resource, validating movement names against the library.
    static func seedBenchmarkWODs(context: ModelContext) {
        // Check if benchmarks already exist
        let descriptor = FetchDescriptor<WOD>(predicate: #Predicate { $0.isBenchmark == true })
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        guard existingCount == 0 else { return }
        
        // Load all movement names from library for validation
        let movementDescriptor = FetchDescriptor<MovementLibraryItem>()
        let existingMovements = (try? context.fetch(movementDescriptor)) ?? []
        let knownNames = Set(existingMovements.map(\.name))
        
        let benchmarks = DefaultMovements.benchmarkWODs()
        for wod in benchmarks {
            // Validate that all movements in the WoD exist in the library
            let allExist = wod.movements.allSatisfy { knownNames.contains($0.movementName) }
            if !allExist {
                let missing = wod.movements.filter { !knownNames.contains($0.movementName) }
                print("⚠️ [DataSeeder] WOD '\(wod.name)' references unknown movements: \(missing.map(\.movementName))")
            }
            context.insert(wod)
        }
        
        try? context.save()
    }
    
    static func seedDefaultProfile(context: ModelContext) {
        let descriptor = FetchDescriptor<UserProfile>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        guard existingCount == 0 else { return }
        
        let profile = UserProfile()
        context.insert(profile)
        try? context.save()
    }
    
    static func seedMovementLibrary(context: ModelContext) {
        // Check if default movements already exist
        let descriptor = FetchDescriptor<MovementLibraryItem>(predicate: #Predicate { $0.isDefault == true })
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        guard existingCount == 0 else { return }
        
        let defaults = DefaultMovements.all()
        for movement in defaults {
            context.insert(movement)
        }
        
        try? context.save()
    }
}
