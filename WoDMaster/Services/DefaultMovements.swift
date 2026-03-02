//
//  DefaultMovements.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation

/// Factory that produces all default CrossFit movements and benchmark WODs.
///
/// Data is loaded from `Resources/DefaultMovements.json` and `Resources/BenchmarkWODs.json`
/// via `MovementLoader`. This keeps data separate from application logic and makes it easy to:
/// - Maintain and review definitions without recompiling
/// - Support future remote updates via CloudKit
/// - Write unit tests with custom JSON fixtures
struct DefaultMovements {
    
    /// Load all default movements from the bundled JSON resource.
    static func all() -> [MovementLibraryItem] {
        return MovementLoader.loadDefaultMovements()
    }
    
    /// Load all benchmark WODs from the bundled JSON resource.
    static func benchmarkWODs() -> [WOD] {
        return MovementLoader.loadBenchmarkWODs()
    }
}
