//
//  WorkoutHistoryView.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import SwiftUI
import SwiftData

struct WorkoutHistoryView: View {
    @Query(sort: \WorkoutResult.date, order: .reverse) private var results: [WorkoutResult]
    @State private var selectedResult: WorkoutResult?
    
    var body: some View {
        NavigationStack {
            Group {
                if results.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(results) { result in
                            Button(action: { selectedResult = result }) {
                                resultRow(result)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("History 📊")
            .sheet(item: $selectedResult) { result in
                WorkoutReportView(result: result)
            }
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Workouts Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Complete your first WOD to see your history here!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    func resultRow(_ result: WorkoutResult) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.wodName)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Text(result.scaling.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(scalingColor(result.scaling).opacity(0.2))
                        )
                        .foregroundColor(scalingColor(result.scaling))
                    
                    Text(result.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(result.scoreDisplay)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
    
    func scalingColor(_ scaling: WorkoutScaling) -> Color {
        switch scaling {
        case .rx: return .green
        case .scaled: return .blue
        case .rxPlus: return .purple
        }
    }
}

#Preview {
    WorkoutHistoryView()
        .modelContainer(for: [WorkoutResult.self], inMemory: true)
}
