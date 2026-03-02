//
//  WorkoutResult.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation
import SwiftData

// MARK: - Round Split
@Model
final class RoundSplit {
    var id: UUID
    var roundNumber: Int
    var duration: Double // in seconds
    var repsCompleted: Int
    var notes: String
    
    init(roundNumber: Int, duration: Double, repsCompleted: Int = 0, notes: String = "") {
        self.id = UUID()
        self.roundNumber = roundNumber
        self.duration = duration
        self.repsCompleted = repsCompleted
        self.notes = notes
    }
    
    var durationFormatted: String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        return "\(mins):\(String(format: "%02d", secs))"
    }
}

// MARK: - Workout Scaling
enum WorkoutScaling: String, Codable, CaseIterable, Identifiable {
    case rx = "Rx"
    case scaled = "Scaled"
    case rxPlus = "Rx+"
    
    var id: String { rawValue }
}

// MARK: - Workout Result
@Model
final class WorkoutResult {
    var id: UUID
    var wod: WOD?
    var wodName: String // denormalized for display
    var date: Date
    var totalTime: Double? // in seconds, for "For Time"
    var totalRounds: Int? // for AMRAP
    var extraReps: Int? // extra reps beyond complete rounds in AMRAP
    var scaling: WorkoutScaling
    var splits: [RoundSplit]
    var notes: String
    var heartRateAvg: Int?
    var heartRateMax: Int?
    var rxWeights: [String: Double] // movement name -> weight used
    
    init(wod: WOD? = nil, wodName: String, date: Date = Date(), totalTime: Double? = nil, totalRounds: Int? = nil, extraReps: Int? = nil, scaling: WorkoutScaling = .rx, splits: [RoundSplit] = [], notes: String = "", rxWeights: [String: Double] = [:]) {
        self.id = UUID()
        self.wod = wod
        self.wodName = wodName
        self.date = date
        self.totalTime = totalTime
        self.totalRounds = totalRounds
        self.extraReps = extraReps
        self.scaling = scaling
        self.splits = splits
        self.notes = notes
        self.rxWeights = rxWeights
    }
    
    var totalTimeFormatted: String {
        guard let time = totalTime else { return "--:--" }
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return "\(mins):\(String(format: "%02d", secs))"
    }
    
    var scoreDisplay: String {
        if let rounds = totalRounds {
            if let extra = extraReps, extra > 0 {
                return "\(rounds)+\(extra)"
            }
            return "\(rounds) rounds"
        }
        if let time = totalTime {
            let mins = Int(time) / 60
            let secs = Int(time) % 60
            return "\(mins):\(String(format: "%02d", secs))"
        }
        return "N/A"
    }
}

// MARK: - Scaling Suggestion
struct ScalingSuggestion: Identifiable {
    let id = UUID()
    let movementName: String
    let rxWeight: Double?
    let suggestedWeight: Double?
    let suggestedReps: Int?
    let reason: String
    let weightUnit: WeightUnit
    
    init(movementName: String, rxWeight: Double?, suggestedWeight: Double?, suggestedReps: Int?, reason: String, weightUnit: WeightUnit = .kg) {
        self.movementName = movementName
        self.rxWeight = rxWeight
        self.suggestedWeight = suggestedWeight
        self.suggestedReps = suggestedReps
        self.reason = reason
        self.weightUnit = weightUnit
    }
    
    /// Format Rx weight for display using the movement's own unit
    var rxDisplayString: String {
        guard let rx = rxWeight else { return "" }
        return formatValue(rx)
    }
    
    /// Format suggested weight for display using the movement's own unit
    var suggestedDisplayString: String {
        guard let w = suggestedWeight else { return "" }
        return formatValue(w)
    }
    
    private func formatValue(_ value: Double) -> String {
        if value == value.rounded() {
            return "\(Int(value)) \(weightUnit.rawValue)"
        }
        return "\(String(format: "%.1f", value)) \(weightUnit.rawValue)"
    }
}

// MARK: - Workout Analysis Report
struct WorkoutAnalysisReport: Identifiable {
    let id = UUID()
    let wodName: String
    let totalTime: Double
    let splits: [RoundSplit]
    let averageSplitTime: Double
    let fastestSplit: RoundSplit?
    let slowestSplit: RoundSplit?
    let paceVariation: Double // percentage
    let insights: [String]
    let suggestions: [String]
    let overallRating: Int // 1-5 stars
}
