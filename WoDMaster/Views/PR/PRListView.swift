//
//  PRListView.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import SwiftUI
import SwiftData

struct PRListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PersonalRecord.date, order: .reverse) private var records: [PersonalRecord]
    @Query(sort: \MovementLibraryItem.name) private var movements: [MovementLibraryItem]
    @Query private var profiles: [UserProfile]
    @State private var showingAddPR = false
    
    var weightUnit: WeightUnit { profiles.first?.preferredWeightUnit ?? .kg }
    
    // Group PRs by movement name
    var groupedRecords: [(String, String, [PersonalRecord])] {
        let dict = Dictionary(grouping: records) { $0.movementName }
        return dict.sorted { $0.key < $1.key }.map { name, prs in
            let icon = movements.first(where: { $0.name == name })?.icon ?? "star.fill"
            return (name, icon, prs)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(groupedRecords, id: \.0) { movementName, icon, prs in
                            Section {
                                ForEach(prs) { pr in
                                    prRow(pr)
                                }
                                .onDelete { offsets in
                                    deletePRs(from: prs, at: offsets)
                                }
                            } header: {
                                HStack(spacing: 8) {
                                    Image(systemName: icon)
                                        .foregroundColor(.orange)
                                    Text(movementName)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Personal Records 🏆")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPR = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddPR) {
                AddPRView()
            }
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No PRs Recorded")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add your personal records to get personalized scaling suggestions!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddPR = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Your First PR")
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding(40)
    }
    
    func prRow(_ pr: PersonalRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(pr.prType.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(Color.orange.opacity(0.2))
                        )
                        .foregroundColor(.orange)
                    
                    Text(pr.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                if !pr.notes.isEmpty {
                    Text(pr.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(pr.displayValue(unit: weightUnit))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 2)
    }
    
    func deletePRs(from prs: [PersonalRecord], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(prs[index])
        }
    }
}

#Preview {
    PRListView()
        .modelContainer(for: [PersonalRecord.self, UserProfile.self, MovementLibraryItem.self], inMemory: true)
}
