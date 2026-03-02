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
    let tags: [String]?
    let hasWeight: Bool
    let hasDistance: Bool
    let hasCalories: Bool
    let hasTime: Bool
    let allowedPRTypes: [String]
    let defaultRxWeightMale: Double?
    let defaultRxWeightFemale: Double?
    
    /// Convert this DTO into a SwiftData MovementLibraryItem
    func toMovementLibraryItem() -> MovementLibraryItem {
        let cat = MovementCategory(rawValue: category) ?? .lift
        let prTypes = allowedPRTypes.compactMap { AllowedPRType(rawValue: $0) }
        let movementTags = (tags ?? []).compactMap { MovementTag(rawValue: $0) }
        
        return MovementLibraryItem(
            name: name,
            category: cat,
            isDefault: true,
            tags: movementTags,
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

/// DTO for decoding benchmark WoD data from JSON.
struct BenchmarkWODDTO: Codable {
    let name: String
    let wodType: String
    let description: String
    let timeCap: Int?
    let rounds: Int?
    let emomInterval: Int?
    let movements: [WODMovementDTO]
    
    struct WODMovementDTO: Codable {
        let movementName: String
        let reps: Int
        let weight: Double?
        let distance: Double?
        let calories: Int?
        let order: Int
    }
}

/// Service responsible for loading default movements and WoDs from JSON resource files.
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
    
    /// Load benchmark WoDs from the bundled JSON file.
    /// - Parameter bundle: The bundle containing the JSON resource (default: .main)
    /// - Returns: An array of WOD ready to be inserted into SwiftData
    static func loadBenchmarkWODs(from bundle: Bundle = .main) -> [WOD] {
        guard let url = bundle.url(forResource: "BenchmarkWODs", withExtension: "json") else {
            print("⚠️ [MovementLoader] BenchmarkWODs.json not found in bundle")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let dtos = try decoder.decode([BenchmarkWODDTO].self, from: data)
            return dtos.map { dto in
                let movements = dto.movements.map { m in
                    WODMovement(
                        movementName: m.movementName,
                        reps: m.reps,
                        weight: m.weight,
                        distance: m.distance,
                        calories: m.calories,
                        order: m.order
                    )
                }
                let wodType = WODType(rawValue: dto.wodType) ?? .forTime
                return WOD(
                    name: dto.name,
                    wodType: wodType,
                    wodDescription: dto.description,
                    timeCap: dto.timeCap,
                    rounds: dto.rounds,
                    emomInterval: dto.emomInterval,
                    movements: movements,
                    isBenchmark: true
                )
            }
        } catch {
            print("⚠️ [MovementLoader] Failed to decode BenchmarkWODs.json: \(error)")
            return []
        }
    }
    
    /// Load and return just the movement DTOs (useful for validation/testing without SwiftData)
    static func loadMovementDTOs(from bundle: Bundle = .main) -> [MovementDTO] {
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