//
//  WODListView.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import SwiftUI
import SwiftData

struct WODListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WOD.name) private var wods: [WOD]
    @State private var showingAddWOD = false
    @State private var searchText = ""
    @State private var selectedFilter: WODFilterType = .all
    
    enum WODFilterType: String, CaseIterable {
        case all = "All"
        case benchmark = "Benchmark"
        case custom = "Custom"
    }
    
    var filteredWODs: [WOD] {
        var result = wods
        
        switch selectedFilter {
        case .benchmark:
            result = result.filter { $0.isBenchmark }
        case .custom:
            result = result.filter { !$0.isBenchmark }
        case .all:
            break
        }
        
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(WODFilterType.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // WOD List
                ForEach(filteredWODs) { wod in
                    NavigationLink(destination: WODDetailView(wod: wod)) {
                        WODRowView(wod: wod)
                    }
                }
                .onDelete(perform: deleteWODs)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("WODs 💪")
            .searchable(text: $searchText, prompt: "Search WODs...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddWOD = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddWOD) {
                AddWODView()
            }
        }
    }
    
    private func deleteWODs(offsets: IndexSet) {
        for index in offsets {
            let wod = filteredWODs[index]
            if !wod.isBenchmark {
                modelContext.delete(wod)
            }
        }
    }
}

// MARK: - WOD Row View
struct WODRowView: View {
    let wod: WOD
    
    var body: some View {
        HStack(spacing: 12) {
            // Type Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(wod.isBenchmark ? Color.orange.opacity(0.2) : Color.blue.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: wod.wodType.icon)
                    .font(.title3)
                    .foregroundColor(wod.isBenchmark ? .orange : .blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(wod.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if wod.isBenchmark {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Text(wod.wodType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let timeCap = wod.timeCap {
                    Text("Cap: \(timeCap / 60) min")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Movement count
            VStack {
                Text("\(wod.movements.count)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("moves")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WODListView()
        .modelContainer(for: [WOD.self], inMemory: true)
}
