//
//  MovementLibraryItem.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation
import SwiftData

// MARK: - Movement Category
enum MovementCategory: String, Codable, CaseIterable, Identifiable {
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case kettlebell = "Kettlebell"
    case gymnastics = "Gymnastics"
    case monostructural = "Monostructural"
    case weightedBodyweight = "Weighted Bodyweight"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .barbell: return "figure.strengthtraining.traditional"
        case .dumbbell: return "dumbbell.fill"
        case .kettlebell: return "figure.cross.training"
        case .gymnastics: return "figure.climbing"
        case .monostructural: return "figure.run"
        case .weightedBodyweight: return "figure.highintensity.intervaltraining"
        case .other: return "star.fill"
        }
    }
}

// MARK: - Allowed PR Types for a Movement
enum AllowedPRType: String, Codable, CaseIterable, Identifiable {
    case oneRM = "1RM"
    case threeRM = "3RM"
    case fiveRM = "5RM"
    case maxReps = "Max Reps"
    case maxDistance = "Max Distance"
    case bestTime = "Best Time"
    case maxCalories = "Max Calories"
    case maxDuration = "Max Duration" // e.g., max hold time for L-sit
    
    var id: String { rawValue }
}

// MARK: - Movement Library Item
/// Represents a single movement in the movement library.
/// Each movement defines which properties can be edited (weight, distance, etc.)
/// and which PR types are applicable.
@Model
final class MovementLibraryItem {
    var id: UUID
    var name: String
    var category: MovementCategory
    var isDefault: Bool // true for built-in movements, false for user-created
    
    // Editable property flags — determines what fields appear in the WOD movement editor
    var hasWeight: Bool       // e.g., Back Squat, Thruster
    var hasDistance: Bool      // e.g., Run, Row, Walking Lunge
    var hasCalories: Bool      // e.g., Row, Bike, Ski Erg
    var hasTime: Bool          // e.g., Wall Sit, Plank hold (duration-based)
    
    // Allowed PR types (stored as comma-separated raw values for SwiftData compatibility)
    var allowedPRTypesRaw: String
    
    /// Rx default weight for male in kg (used in classic WODs)
    var defaultRxWeightMale: Double?
    /// Rx default weight for female in kg
    var defaultRxWeightFemale: Double?
    
    var createdAt: Date
    
    // MARK: - Computed Properties
    
    var allowedPRTypes: [AllowedPRType] {
        get {
            allowedPRTypesRaw.split(separator: ",").compactMap { AllowedPRType(rawValue: String($0)) }
        }
        set {
            allowedPRTypesRaw = newValue.map(\.rawValue).joined(separator: ",")
        }
    }
    
    init(
        name: String,
        category: MovementCategory,
        isDefault: Bool = true,
        hasWeight: Bool = false,
        hasDistance: Bool = false,
        hasCalories: Bool = false,
        hasTime: Bool = false,
        allowedPRTypes: [AllowedPRType] = [],
        defaultRxWeightMale: Double? = nil,
        defaultRxWeightFemale: Double? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.isDefault = isDefault
        self.hasWeight = hasWeight
        self.hasDistance = hasDistance
        self.hasCalories = hasCalories
        self.hasTime = hasTime
        self.allowedPRTypesRaw = allowedPRTypes.map(\.rawValue).joined(separator: ",")
        self.defaultRxWeightMale = defaultRxWeightMale
        self.defaultRxWeightFemale = defaultRxWeightFemale
        self.createdAt = Date()
    }
    
    /// Icon based on category
    var icon: String { category.icon }
    
    /// Short description of editable properties
    var propertyTags: [String] {
        var tags: [String] = []
        if hasWeight { tags.append("Weight") }
        if hasDistance { tags.append("Distance") }
        if hasCalories { tags.append("Calories") }
        if hasTime { tags.append("Time") }
        if tags.isEmpty { tags.append("Reps Only") }
        return tags
    }
}
