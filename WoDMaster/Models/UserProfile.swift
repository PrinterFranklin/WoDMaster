//
//  UserProfile.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation
import SwiftData

// MARK: - Weight Unit
enum WeightUnit: String, Codable, CaseIterable, Identifiable {
    case kg = "kg"
    case lb = "lb"
    
    var id: String { rawValue }
    
    /// Convert a value stored in kg to this unit for display
    func fromKg(_ kg: Double) -> Double {
        switch self {
        case .kg: return kg
        case .lb: return kg * 2.20462
        }
    }
    
    /// Convert a value in this unit to kg for storage
    func toKg(_ value: Double) -> Double {
        switch self {
        case .kg: return value
        case .lb: return value / 2.20462
        }
    }
    
    /// Format a weight value (stored in kg) for display in this unit
    func displayString(_ kgValue: Double) -> String {
        let converted = fromKg(kgValue)
        if converted == converted.rounded() {
            return "\(Int(converted)) \(rawValue)"
        }
        return "\(String(format: "%.1f", converted)) \(rawValue)"
    }
    
    /// Round to nearest standard plate increment
    func roundToPlate(_ kgValue: Double) -> Double {
        switch self {
        case .kg:
            return (kgValue / 2.5).rounded() * 2.5
        case .lb:
            let lbValue = fromKg(kgValue)
            let rounded = (lbValue / 5.0).rounded() * 5.0
            return toKg(rounded)
        }
    }
}

// MARK: - Fitness Level
enum FitnessLevel: String, Codable, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case elite = "Elite"
    
    var id: String { rawValue }
    
    var scalingFactor: Double {
        switch self {
        case .beginner: return 0.5
        case .intermediate: return 0.7
        case .advanced: return 0.9
        case .elite: return 1.0
        }
    }
}

// MARK: - Gender
enum Gender: String, Codable, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    
    var id: String { rawValue }
}

// MARK: - User Profile
@Model
final class UserProfile {
    var id: UUID
    var name: String
    var gender: Gender
    var bodyWeight: Double // in kg
    var height: Double // in cm
    var fitnessLevel: FitnessLevel
    var crossfitSince: Date?
    var boxName: String // CrossFit box name
    var weightUnit: WeightUnit?
    var createdAt: Date
    
    /// Safe accessor that defaults to .kg for records migrated from older schema
    var preferredWeightUnit: WeightUnit {
        get { weightUnit ?? .kg }
        set { weightUnit = newValue }
    }
    
    init(name: String = "", gender: Gender = .male, bodyWeight: Double = 75.0, height: Double = 175.0, fitnessLevel: FitnessLevel = .intermediate, crossfitSince: Date? = nil, boxName: String = "", weightUnit: WeightUnit = .kg) {
        self.id = UUID()
        self.name = name
        self.gender = gender
        self.bodyWeight = bodyWeight
        self.height = height
        self.fitnessLevel = fitnessLevel
        self.crossfitSince = crossfitSince
        self.boxName = boxName
        self.weightUnit = weightUnit
        self.createdAt = Date()
    }
}
