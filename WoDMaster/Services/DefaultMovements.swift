//
//  DefaultMovements.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation

/// Factory that produces all default CrossFit movements.
///
/// Data is loaded from `Resources/DefaultMovements.json` via `MovementLoader`.
/// This keeps movement data separate from application logic and makes it easy to:
/// - Maintain and review movement definitions without recompiling
/// - Support future remote updates or localization
/// - Write unit tests with custom JSON fixtures
struct DefaultMovements {
    
    /// Load all default movements from the bundled JSON resource.
    /// Falls back to an empty array if the JSON file is missing or malformed.
    static func all() -> [MovementLibraryItem] {
        return MovementLoader.loadDefaultMovements()
    }
}
