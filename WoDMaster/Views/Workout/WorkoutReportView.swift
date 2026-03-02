//
//  WorkoutReportView.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import SwiftUI

struct WorkoutReportView: View {
    let result: WorkoutResult
    @Environment(\.dismiss) private var dismiss
    
    var report: WorkoutAnalysisReport {
        WorkoutEngine.generateAnalysisReport(from: result)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Score Card
                    scoreCard
                    
                    // Splits Chart
                    splitsSection
                    
                    // Insights
                    insightsSection
                    
                    // Suggestions
                    suggestionsSection
                    
                    // Rating
                    ratingSection
                }
                .padding()
            }
            .navigationTitle("Workout Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    // MARK: - Header
    var headerSection: some View {
        VStack(spacing: 8) {
            Text("🏋️ Workout Complete!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(report.wodName)
                .font(.largeTitle)
                .fontWeight(.black)
                .foregroundColor(.orange)
            
            Text(result.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Score Card
    var scoreCard: some View {
        HStack(spacing: 20) {
            statBox(title: "Total Time", value: TimeFormatter.formatLong(seconds: report.totalTime), color: .orange)
            statBox(title: "Avg Split", value: TimeFormatter.formatShort(seconds: report.averageSplitTime), color: .blue)
            statBox(title: "Rounds", value: "\(report.splits.count)", color: .green)
        }
    }
    
    func statBox(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
    
    // MARK: - Splits Section
    var splitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Split Times")
                .font(.title3)
                .fontWeight(.bold)
            
            if !report.splits.isEmpty {
                let maxDuration = report.splits.map(\.duration).max() ?? 1
                
                ForEach(report.splits) { split in
                    HStack(spacing: 12) {
                        Text("R\(split.roundNumber)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 30)
                            .foregroundColor(.secondary)
                        
                        GeometryReader { geo in
                            let width = geo.size.width * CGFloat(split.duration / maxDuration)
                            let barColor = splitBarColor(split: split)
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 24)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(barColor)
                                    .frame(width: max(width, 30), height: 24)
                            }
                        }
                        .frame(height: 24)
                        
                        Text(split.durationFormatted)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 50, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    func splitBarColor(split: RoundSplit) -> Color {
        guard let fastest = report.fastestSplit, let slowest = report.slowestSplit else { return .blue }
        if split.id == fastest.id { return .green }
        if split.id == slowest.id { return .red }
        return .blue
    }
    
    // MARK: - Insights Section
    var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Insights")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            ForEach(report.insights, id: \.self) { insight in
                Text(insight)
                    .font(.body)
                    .padding(.vertical, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.yellow.opacity(0.1))
        )
    }
    
    // MARK: - Suggestions Section
    var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.up.right.circle.fill")
                    .foregroundColor(.green)
                Text("Suggestions")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            ForEach(report.suggestions, id: \.self) { suggestion in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.caption)
                        .padding(.top, 3)
                    Text(suggestion)
                        .font(.body)
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
        )
    }
    
    // MARK: - Rating
    var ratingSection: some View {
        VStack(spacing: 8) {
            Text("Pacing Rating")
                .font(.headline)
            
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= report.overallRating ? "star.fill" : "star")
                        .font(.title)
                        .foregroundColor(.orange)
                }
            }
            
            Text(ratingText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    var ratingText: String {
        switch report.overallRating {
        case 5: return "Perfect pacing! Elite-level strategy."
        case 4: return "Great pacing! Very consistent effort."
        case 3: return "Good effort. Room for improvement in pacing."
        case 2: return "Uneven pacing. Focus on consistency."
        default: return "Work on your pacing strategy."
        }
    }
}
