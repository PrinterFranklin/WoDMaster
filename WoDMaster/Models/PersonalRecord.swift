//
//  PersonalRecord.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation
import SwiftData

// MARK: - PR Type
enum PRType: String, Codable, CaseIterable, Identifiable {
    case oneRM = "1RM"
    case threeRM = "3RM"
    case fiveRM = "5RM"
    case maxReps = "Max Reps"
    case maxDistance = "Max Distance"
    case bestTime = "Best Time"
    case maxCalories = "Max Calories"
    case maxDuration = "Max Duration"
    
    var id: String { rawValue }
    
    /// Map from AllowedPRType to PRType
    static func from(_ allowed: AllowedPRType) -> PRType? {
        switch allowed {
        case .oneRM: return .oneRM
        case .threeRM: return .threeRM
        case .fiveRM: return .fiveRM
        case .maxReps: return .maxReps
        case .maxDistance: return .maxDistance
        case .bestTime: return .bestTime
        case .maxCalories: return .maxCalories
        case .maxDuration: return .maxDuration
        }
    }
    
    /// The unit string for display
    func unitString(weightUnit: WeightUnit) -> String {
        switch self {
        case .oneRM, .threeRM, .fiveRM: return weightUnit.rawValue
        case .maxReps: return "reps"
        case .maxDistance: return "m"
        case .bestTime: return "sec"
        case .maxCalories: return "cal"
        case .maxDuration: return "sec"
        }
    }
    
    var isWeightBased: Bool {
        switch self {
        case .oneRM, .threeRM, .fiveRM: return true
        default: return false
        }
    }
    
    var isTimeBased: Bool {
        switch self {
        case .bestTime, .maxDuration: return true
        default: return false
        }
    }
}

// MARK: - Personal Record
@Model
final class PersonalRecord {
    var id: UUID
    var movementName: String  // links to MovementLibraryItem.name
    var prType: PRType
    var value: Double // weight in kg, time in seconds, distance in meters, reps count, or calories
    var date: Date
    var notes: String
    
    init(movementName: String, prType: PRType, value: Double, date: Date = Date(), notes: String = "") {
        self.id = UUID()
        self.movementName = movementName
        self.prType = prType
        self.value = value
        self.date = date
        self.notes = notes
    }
    
    var displayValue: String {
        displayValue(unit: .kg)
    }
    
    func displayValue(unit: WeightUnit) -> String {
        if prType.isTimeBased {
            let mins = Int(value) / 60
            let secs = Int(value) % 60
            return "\(mins):\(String(format: "%02d", secs))"
        } else if prType.isWeightBased {
            return unit.displayString(value)
        } else if prType == .maxDistance {
            return "\(Int(value))m"
        } else if prType == .maxCalories {
            return "\(Int(value)) cal"
        } else {
            return "\(Int(value)) reps"
        }
    }
}
