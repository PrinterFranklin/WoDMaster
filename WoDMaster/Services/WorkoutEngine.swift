//
//  WorkoutEngine.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation
import SwiftData

// MARK: - Workout Engine
// Handles scaling suggestions, workout timing, and analysis
class WorkoutEngine {
    
    // MARK: - Scaling Suggestions
    static func generateScalingSuggestions(for wod: WOD, profile: UserProfile, prs: [PersonalRecord]) -> [ScalingSuggestion] {
        var suggestions: [ScalingSuggestion] = []
        let factor = profile.fitnessLevel.scalingFactor
        let genderFactor: Double = profile.gender == .female ? 0.7 : 1.0
        
        for movement in wod.movements {
            guard let rxWeight = movement.weight, rxWeight > 0 else { continue }
            let movementUnit = movement.movementWeightUnit
            
            // Find relevant PR by matching movement name
            let relevantPR = prs.first { pr in
                pr.movementName.lowercased() == movement.movementName.lowercased() ||
                pr.movementName.lowercased().contains(movement.movementName.lowercased()) ||
                movement.movementName.lowercased().contains(pr.movementName.lowercased())
            }
            
            // Calculate suggested weight in kg first
            let rxWeightInKg = movement.weightInKg ?? rxWeight
            var suggestedWeightKg = rxWeightInKg * factor * genderFactor
            var reason = "Based on your fitness level (\(profile.fitnessLevel.rawValue))"
            
            if let pr = relevantPR, pr.prType.isWeightBased {
                // Use PR to calculate: WOD weight should be ~60-70% of 1RM for metabolic conditioning
                let targetPercentage = 0.65
                suggestedWeightKg = pr.value * targetPercentage
                let prUnit = profile.preferredWeightUnit
                reason = "~65% of your \(pr.prType.rawValue) (\(prUnit.displayString(pr.value)))"
            }
            
            // Convert suggested weight to the movement's own unit
            let suggestedWeight = movementUnit.fromKg(suggestedWeightKg)
            // Round to nearest plate increment in the movement's unit
            let roundedSuggested: Double
            if movementUnit == .lb {
                roundedSuggested = (suggestedWeight / 5.0).rounded() * 5.0
            } else {
                roundedSuggested = (suggestedWeight / 2.5).rounded() * 2.5
            }
            
            suggestions.append(ScalingSuggestion(
                movementName: movement.movementName,
                rxWeight: rxWeight,
                suggestedWeight: roundedSuggested,
                suggestedReps: nil,
                reason: reason,
                weightUnit: movementUnit
            ))
        }
        
        return suggestions
    }
    
    // MARK: - Generate Analysis Report
    static func generateAnalysisReport(from result: WorkoutResult) -> WorkoutAnalysisReport {
        let splits = result.splits.sorted { $0.roundNumber < $1.roundNumber }
        
        guard !splits.isEmpty else {
            return WorkoutAnalysisReport(
                wodName: result.wodName,
                totalTime: result.totalTime ?? 0,
                splits: [],
                averageSplitTime: 0,
                fastestSplit: nil,
                slowestSplit: nil,
                paceVariation: 0,
                insights: ["No split data available."],
                suggestions: ["Use the timer to record splits in your next workout."],
                overallRating: 3
            )
        }
        
        let totalTime = result.totalTime ?? splits.reduce(0) { $0 + $1.duration }
        let avgSplit = totalTime / Double(splits.count)
        let fastest = splits.min(by: { $0.duration < $1.duration })
        let slowest = splits.max(by: { $0.duration < $1.duration })
        
        // Calculate pace variation (coefficient of variation)
        let durations = splits.map { $0.duration }
        let mean = durations.reduce(0, +) / Double(durations.count)
        let variance = durations.reduce(0) { $0 + pow($1 - mean, 2) } / Double(durations.count)
        let stdDev = sqrt(variance)
        let paceVariation = mean > 0 ? (stdDev / mean) * 100 : 0
        
        // Generate insights
        var insights: [String] = []
        var suggestions: [String] = []
        
        // Pace analysis
        if paceVariation < 10 {
            insights.append("🎯 Excellent pacing! Your splits are very consistent (variation: \(String(format: "%.1f", paceVariation))%).")
        } else if paceVariation < 20 {
            insights.append("📊 Good pacing with moderate variation (\(String(format: "%.1f", paceVariation))%). Room for improvement.")
        } else {
            insights.append("⚠️ High pace variation (\(String(format: "%.1f", paceVariation))%). You may have started too fast or faded significantly.")
        }
        
        // Split trend analysis
        if splits.count >= 3 {
            let firstHalf = Array(splits.prefix(splits.count / 2))
            let secondHalf = Array(splits.suffix(splits.count - splits.count / 2))
            let firstAvg = firstHalf.reduce(0.0) { $0 + $1.duration } / Double(firstHalf.count)
            let secondAvg = secondHalf.reduce(0.0) { $0 + $1.duration } / Double(secondHalf.count)
            
            if secondAvg > firstAvg * 1.15 {
                insights.append("📉 Negative split: Your pace slowed significantly in the second half.")
                suggestions.append("Try starting at a slightly slower pace to maintain intensity throughout the workout.")
            } else if secondAvg < firstAvg * 0.95 {
                insights.append("📈 Positive split: You got faster as the workout progressed! Great mental toughness.")
                suggestions.append("Consider pushing the pace slightly earlier since you clearly had energy reserves.")
            } else {
                insights.append("⚖️ Even pacing throughout the workout. Well-executed strategy!")
            }
        }
        
        // Fastest/slowest analysis
        if let fast = fastest, let slow = slowest {
            let diff = slow.duration - fast.duration
            if diff > avgSplit * 0.3 {
                insights.append("🔄 Your fastest round (R\(fast.roundNumber): \(fast.durationFormatted)) and slowest round (R\(slow.roundNumber): \(slow.durationFormatted)) differ by \(Int(diff))s.")
                suggestions.append("Focus on maintaining a more consistent effort across all rounds.")
            }
        }
        
        // Recovery suggestions
        if paceVariation > 15 {
            suggestions.append("Work on pacing strategy: set a target split time and use a clock to stay on track.")
        }
        
        suggestions.append("Record this WOD again in 4-6 weeks to track your progress.")
        
        // Overall rating
        let rating: Int
        if paceVariation < 10 { rating = 5 }
        else if paceVariation < 15 { rating = 4 }
        else if paceVariation < 20 { rating = 3 }
        else if paceVariation < 30 { rating = 2 }
        else { rating = 1 }
        
        return WorkoutAnalysisReport(
            wodName: result.wodName,
            totalTime: totalTime,
            splits: splits,
            averageSplitTime: avgSplit,
            fastestSplit: fastest,
            slowestSplit: slowest,
            paceVariation: paceVariation,
            insights: insights,
            suggestions: suggestions,
            overallRating: rating
        )
    }
    
    // MARK: - Target Split Calculator
    static func calculateTargetSplits(for wod: WOD, targetTime: Double) -> [Double] {
        let roundCount = wod.rounds ?? 1
        guard roundCount > 0 else { return [] }
        
        let avgSplit = targetTime / Double(roundCount)
        // Slight positive split strategy: start a bit slower, finish faster
        var splits: [Double] = []
        for i in 0..<roundCount {
            let factor = 1.0 + (Double(roundCount / 2 - i) * 0.02) // slight adjustment
            splits.append(avgSplit * factor)
        }
        
        // Normalize to match target time
        let totalCalc = splits.reduce(0, +)
        let normalFactor = targetTime / totalCalc
        splits = splits.map { $0 * normalFactor }
        
        return splits
    }
}
