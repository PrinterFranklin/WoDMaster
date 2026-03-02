//
//  WODDetailView.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import SwiftUI
import SwiftData

struct WODDetailView: View {
    let wod: WOD
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var prs: [PersonalRecord]
    @State private var showingWorkout = false
    @State private var showingScaling = false
    @State private var showingEdit = false
    @State private var scalingSuggestions: [ScalingSuggestion] = []
    
    var profile: UserProfile? { profiles.first }
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                headerCard
                
                // Movements
                movementsSection
                
                // Scaling Suggestions
                if !scalingSuggestions.isEmpty {
                    scalingSection
                }
                
                // Action Buttons
                actionButtons
            }
            .padding()
        }
        .navigationTitle(wod.name)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if let profile = profile {
                scalingSuggestions = WorkoutEngine.generateScalingSuggestions(for: wod, profile: profile, prs: Array(prs))
            }
        }
        .toolbar {
            if !wod.isBenchmark {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingEdit = true }) {
                        Image(systemName: "pencil.circle")
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showingWorkout) {
            WorkoutTimerView(wod: wod)
        }
        .sheet(isPresented: $showingEdit) {
            AddWODView(editingWOD: wod)
        }
    }
    
    // MARK: - Header Card
    var headerCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: wod.wodType.icon)
                            .foregroundColor(.orange)
                        Text(wod.wodType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    
                    if wod.isBenchmark {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                            Text("Benchmark WOD")
                                .font(.caption)
                        }
                        .foregroundColor(.yellow)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    if let rounds = wod.rounds {
                        Text("\(rounds) Rounds")
                            .font(.headline)
                    }
                    Text(wod.timeCapFormatted)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            Text(wod.wodDescription)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Movements Section
    var movementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Movements")
                .font(.title3)
                .fontWeight(.bold)
            
            ForEach(wod.movements.sorted(by: { $0.order < $1.order })) { movement in
                HStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                    
                    Text(movement.displayString)
                        .font(.body)
                    
                    Spacer()
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Scaling Section
    var scalingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "scalemass.fill")
                    .foregroundColor(.blue)
                Text("Scaling Suggestions")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            ForEach(scalingSuggestions) { suggestion in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(suggestion.movementName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(suggestion.reason)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        if let rx = suggestion.rxWeight {
                            Text("Rx: \(suggestion.rxDisplayString)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .strikethrough()
                        }
                        if let suggested = suggestion.suggestedWeight {
                            Text(suggestion.suggestedDisplayString)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.vertical, 4)
                
                if suggestion.id != scalingSuggestions.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    // MARK: - Action Buttons
    var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: { showingWorkout = true }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Workout")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            
            if !wod.isBenchmark {
                Button(action: { showingEdit = true }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit WOD")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
            }
            
            Button(action: { showingScaling.toggle() }) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Customize Scaling")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(16)
            }
        }
    }
}

#Preview {
    NavigationStack {
        WODDetailView(wod: WOD(name: "Preview WOD", wodType: .forTime, wodDescription: "Preview", isBenchmark: true))
    }
    .modelContainer(for: [WOD.self, PersonalRecord.self, UserProfile.self], inMemory: true)
}
