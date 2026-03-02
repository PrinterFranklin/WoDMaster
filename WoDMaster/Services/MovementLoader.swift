//
//  MovementLoader.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation

/// DTO (Data Transfer Object) for decoding movement data from JSON.
/// This is a plain Codable struct — separate from the SwiftData @Model.
struct MovementDTO: Codable {
    let name: String
    let category: String
    let hasWeight: Bool
    let hasDistance: Bool
    let hasCalories: Bool
    let hasTime: Bool
    let allowedPRTypes: [String]
    let defaultRxWeightMale: Double?
    let defaultRxWeightFemale: Double?
    
    /// Convert this DTO into a SwiftData MovementLibraryItem
    func toMovementLibraryItem() -> MovementLibraryItem {
        let cat = MovementCategory(rawValue: category) ?? .other
        let prTypes = allowedPRTypes.compactMap { AllowedPRType(rawValue: $0) }
        
        return MovementLibraryItem(
            name: name,
            category: cat,
            isDefault: true,
            hasWeight: hasWeight,
            hasDistance: hasDistance,
            hasCalories: hasCalories,
            hasTime: hasTime,
            allowedPRTypes: prTypes,
            defaultRxWeightMale: defaultRxWeightMale,
            defaultRxWeightFemale: defaultRxWeightFemale
        )
    }
}

/// Service responsible for loading default movements from JSON resource files.
struct MovementLoader {
    
    /// Load all default movements from the bundled JSON file.
    /// - Parameter bundle: The bundle containing the JSON resource (default: .main)
    /// - Returns: An array of MovementLibraryItem ready to be inserted into SwiftData
    static func loadDefaultMovements(from bundle: Bundle = .main) -> [MovementLibraryItem] {
        guard let url = bundle.url(forResource: "DefaultMovements", withExtension: "json") else {
            print("⚠️ [MovementLoader] DefaultMovements.json not found in bundle")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let dtos = try decoder.decode([MovementDTO].self, from: data)
            return dtos.map { $0.toMovementLibraryItem() }
        } catch {
            print("⚠️ [MovementLoader] Failed to decode DefaultMovements.json: \(error)")
            return []
        }
    }
    
    /// Load and return just the DTOs (useful for validation/testing without SwiftData)
    static func loadDTOs(from bundle: Bundle = .main) -> [MovementDTO] {
        guard let url = bundle.url(forResource: "DefaultMovements", withExtension: "json") else {
            print("⚠️ [MovementLoader] DefaultMovements.json not found in bundle")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([MovementDTO].self, from: data)
        } catch {
            print("⚠️ [MovementLoader] Failed to decode DefaultMovements.json: \(error)")
            return []
        }
    }
}