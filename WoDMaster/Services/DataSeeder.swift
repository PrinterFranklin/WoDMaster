//
//  DataSeeder.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation
import SwiftData

struct DataSeeder {
    static func seedClassicWODs(context: ModelContext) {
        // Check if classics already exist
        let descriptor = FetchDescriptor<WOD>(predicate: #Predicate { $0.isClassic == true })
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        
        guard existingCount == 0 else { return }
        
        let classics = ClassicWODs.allClassicWODs()
        for wod in classics {
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
