//
//  WOD.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation
import SwiftData

// MARK: - WOD Type
enum WODType: String, Codable, CaseIterable, Identifiable {
    case forTime = "For Time"
    case amrap = "AMRAP"
    case emom = "EMOM"
    case tabata = "Tabata"
    case chipper = "Chipper"
    case ladder = "Ladder"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .forTime: return "timer"
        case .amrap: return "repeat"
        case .emom: return "clock.badge.checkmark"
        case .tabata: return "bolt.fill"
        case .chipper: return "list.number"
        case .ladder: return "chart.bar.fill"
        case .custom: return "square.and.pencil"
        }
    }
}

// MARK: - WOD Movement (movement within a WOD)
@Model
final class WODMovement {
    var id: UUID
    var movementName: String  // Must match a name in MovementLibraryItem
    var reps: Int
    var weight: Double? // stored in the unit specified by weightUnit
    var weightUnit: WeightUnit? // the unit for this movement's weight (nil defaults to .kg)
    var distance: Double? // in meters, for runs/rows
    var calories: Int? // for row/bike
    var order: Int
    
    /// Safe accessor that defaults to .kg for records without a weightUnit
    var movementWeightUnit: WeightUnit {
        get { weightUnit ?? .kg }
        set { weightUnit = newValue }
    }
    
    /// Get weight in kg (for internal calculations like scaling suggestions)
    var weightInKg: Double? {
        guard let w = weight else { return nil }
        return movementWeightUnit.toKg(w)
    }
    
    init(movementName: String, reps: Int, weight: Double? = nil, weightUnit: WeightUnit = .kg, distance: Double? = nil, calories: Int? = nil, order: Int = 0) {
        self.id = UUID()
        self.movementName = movementName
        self.reps = reps
        self.weight = weight
        self.weightUnit = weightUnit
        self.distance = distance
        self.calories = calories
        self.order = order
    }
    
    /// Display string using the movement's own unit
    var displayString: String {
        var parts: [String] = []
        parts.append("\(reps)")
        parts.append(movementName)
        if let w = weight {
            let unit = movementWeightUnit
            if w == w.rounded() {
                parts.append("(\(Int(w)) \(unit.rawValue))")
            } else {
                parts.append("(\(String(format: "%.1f", w)) \(unit.rawValue))")
            }
        }
        if let d = distance {
            parts.append("(\(Int(d))m)")
        }
        if let c = calories {
            parts.append("(\(c) cal)")
        }
        return parts.joined(separator: " ")
    }
}

// MARK: - WOD
@Model
final class WOD {
    var id: UUID
    var name: String
    var wodType: WODType
    var wodDescription: String
    var timeCap: Int? // in seconds
    var rounds: Int? // for AMRAP rounds or For Time rounds
    var emomInterval: Int? // in seconds for EMOM
    var movements: [WODMovement]
    var isBenchmark: Bool // true for official benchmark WODs loaded from JSON/CloudKit
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutResult.wod)
    var results: [WorkoutResult]?
    
    init(name: String, wodType: WODType, wodDescription: String = "", timeCap: Int? = nil, rounds: Int? = nil, emomInterval: Int? = nil, movements: [WODMovement] = [], isBenchmark: Bool = false) {
        self.id = UUID()
        self.name = name
        self.wodType = wodType
        self.wodDescription = wodDescription
        self.timeCap = timeCap
        self.rounds = rounds
        self.emomInterval = emomInterval
        self.movements = movements
        self.isBenchmark = isBenchmark
        self.createdAt = Date()
    }
    
    var timeCapFormatted: String {
        guard let tc = timeCap else { return "No cap" }
        let mins = tc / 60
        let secs = tc % 60
        return secs > 0 ? "\(mins):\(String(format: "%02d", secs))" : "\(mins) min"
    }
    
    var totalReps: Int {
        let singleRoundReps = movements.reduce(0) { $0 + $1.reps }
        return singleRoundReps * (rounds ?? 1)
    }
}
