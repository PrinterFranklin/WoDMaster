//
//  MovementLibraryItem.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation
import SwiftData

// MARK: - Movement Category
/// Three core movement categories for CrossFit training:
/// - Lift: Weighted movements using barbells, dumbbells, kettlebells, etc.
/// - Gym: Bodyweight gymnastics movements (pull-ups, muscle-ups, HSPU, etc.)
/// - Cardio: Monostructural/endurance movements (run, row, bike, jump rope, etc.)
enum MovementCategory: String, Codable, CaseIterable, Identifiable {
    case lift = "Lift"
    case gym = "Gym"
    case cardio = "Cardio"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .lift: return "figure.strengthtraining.traditional"
        case .gym: return "figure.climbing"
        case .cardio: return "figure.run"
        }
    }
    
    var description: String {
        switch self {
        case .lift: return "Weighted Movements"
        case .gym: return "Bodyweight / Gymnastics"
        case .cardio: return "Cardio / Monostructural"
        }
    }
}

// MARK: - Movement Tag
/// Tags for fine-grained equipment/style classification.
/// A movement can have multiple tags (e.g., a Barbell Lunge is both "Barbell" and "Lunge").
enum MovementTag: String, Codable, CaseIterable, Identifiable {
    // Equipment tags
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case kettlebell = "Kettlebell"
    case ring = "Ring"
    case bar = "Bar"                // pull-up bar
    case rope = "Rope"
    case box = "Box"
    case wallBall = "Wall Ball"
    case sled = "Sled"
    case sandbag = "Sandbag"
    case machine = "Machine"        // rower, bike erg, ski erg
    case jumpRope = "Jump Rope"
    
    // Movement pattern tags
    case squat = "Squat"
    case pull = "Pull"
    case push = "Push"
    case hinge = "Hinge"            // deadlift, clean, snatch patterns
    case carry = "Carry"
    case core = "Core"
    case overhead = "Overhead"
    case olympic = "Olympic"        // olympic lifting movements
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .barbell: return "figure.strengthtraining.traditional"
        case .dumbbell: return "dumbbell.fill"
        case .kettlebell: return "figure.cross.training"
        case .ring: return "circle.circle"
        case .bar: return "rectangle.split.3x1"
        case .rope: return "line.diagonal"
        case .box: return "square.fill"
        case .wallBall: return "circle.fill"
        case .sled: return "arrow.right.square"
        case .sandbag: return "bag.fill"
        case .machine: return "gearshape.fill"
        case .jumpRope: return "infinity"
        case .squat: return "arrow.down"
        case .pull: return "arrow.up"
        case .push: return "arrow.right"
        case .hinge: return "arrow.up.right"
        case .carry: return "figure.walk"
        case .core: return "staroflife"
        case .overhead: return "arrow.up.to.line"
        case .olympic: return "trophy"
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
    
    /// Tags for equipment/style classification (stored as comma-separated raw values)
    var tagsRaw: String
    
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
    
    var tags: [MovementTag] {
        get {
            tagsRaw.split(separator: ",").compactMap { MovementTag(rawValue: String($0)) }
        }
        set {
            tagsRaw = newValue.map(\.rawValue).joined(separator: ",")
        }
    }
    
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
        tags: [MovementTag] = [],
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
        self.tagsRaw = tags.map(\.rawValue).joined(separator: ",")
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
        var result: [String] = []
        if hasWeight { result.append("Weight") }
        if hasDistance { result.append("Distance") }
        if hasCalories { result.append("Calories") }
        if hasTime { result.append("Time") }
        if result.isEmpty { result.append("Reps Only") }
        return result
    }
    
    /// Check if this movement has a specific tag
    func hasTag(_ tag: MovementTag) -> Bool {
        tags.contains(tag)
    }
}
