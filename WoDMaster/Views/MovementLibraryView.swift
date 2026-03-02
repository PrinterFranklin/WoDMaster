//
//  MovementLibraryView.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import SwiftUI
import SwiftData

struct MovementLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MovementLibraryItem.name) private var movements: [MovementLibraryItem]
    
    @State private var searchText = ""
    @State private var selectedCategory: MovementCategory?
    @State private var showingAddMovement = false
    
    var filteredMovements: [MovementLibraryItem] {
        var result = movements
        if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }
    
    var groupedMovements: [(MovementCategory, [MovementLibraryItem])] {
        let dict = Dictionary(grouping: filteredMovements) { $0.category }
        return MovementCategory.allCases.compactMap { cat in
            guard let items = dict[cat], !items.isEmpty else { return nil }
            return (cat, items.sorted { $0.name < $1.name })
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if movements.isEmpty {
                    emptyState
                } else {
                    List {
                        // Category filter chips
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    categoryChip(nil, label: "All")
                                    ForEach(MovementCategory.allCases) { cat in
                                        categoryChip(cat, label: cat.rawValue)
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        
                        ForEach(groupedMovements, id: \.0) { category, items in
                            Section {
                                ForEach(items) { item in
                                    movementRow(item)
                                }
                                .onDelete { offsets in
                                    deleteMovements(from: items, at: offsets)
                                }
                            } header: {
                                HStack(spacing: 8) {
                                    Image(systemName: category.icon)
                                        .foregroundColor(.orange)
                                    Text(category.rawValue)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: $searchText, prompt: "Search movements...")
                }
            }
            .navigationTitle("Movement Library 💪")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMovement = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddMovement) {
                AddCustomMovementView()
            }
        }
    }
    
    // MARK: - Subviews
    
    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.cross.training")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("Movement Library Empty")
                .font(.title2)
                .fontWeight(.bold)
            Text("Movements will be loaded when the app starts.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(40)
    }
    
    func categoryChip(_ category: MovementCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category
        return Button(action: { selectedCategory = category }) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.orange : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
    
    func movementRow(_ item: MovementLibraryItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    if item.isDefault {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                
                HStack(spacing: 4) {
                    ForEach(item.propertyTags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(tagColor(for: tag).opacity(0.15))
                            .foregroundColor(tagColor(for: tag))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: item.icon)
                .foregroundColor(.orange)
        }
        .padding(.vertical, 2)
    }
    
    func tagColor(for tag: String) -> Color {
        switch tag {
        case "Weight": return .red
        case "Distance": return .blue
        case "Calories": return .green
        case "Time": return .purple
        default: return .gray
        }
    }
    
    func deleteMovements(from items: [MovementLibraryItem], at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            if !item.isDefault {
                modelContext.delete(item)
            }
        }
    }
}

// MARK: - Add Custom Movement View
struct AddCustomMovementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var category: MovementCategory = .other
    @State private var hasWeight = false
    @State private var hasDistance = false
    @State private var hasCalories = false
    @State private var hasTime = false
    @State private var selectedPRTypes: Set<AllowedPRType> = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Movement Info") {
                    TextField("Movement Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(MovementCategory.allCases) { cat in
                            HStack {
                                Image(systemName: cat.icon)
                                Text(cat.rawValue)
                            }
                            .tag(cat)
                        }
                    }
                }
                
                Section("Editable Properties") {
                    Toggle("Weight", isOn: $hasWeight)
                    Toggle("Distance", isOn: $hasDistance)
                    Toggle("Calories", isOn: $hasCalories)
                    Toggle("Time / Duration", isOn: $hasTime)
                }
                
                Section("Allowed PR Types") {
                    ForEach(AllowedPRType.allCases) { prType in
                        Button(action: { togglePRType(prType) }) {
                            HStack {
                                Text(prType.rawValue)
                                Spacer()
                                if selectedPRTypes.contains(prType) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("New Movement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveMovement() }
                        .disabled(name.isEmpty)
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    func togglePRType(_ type: AllowedPRType) {
        if selectedPRTypes.contains(type) {
            selectedPRTypes.remove(type)
        } else {
            selectedPRTypes.insert(type)
        }
    }
    
    func saveMovement() {
        let item = MovementLibraryItem(
            name: name,
            category: category,
            isDefault: false,
            hasWeight: hasWeight,
            hasDistance: hasDistance,
            hasCalories: hasCalories,
            hasTime: hasTime,
            allowedPRTypes: Array(selectedPRTypes)
        )
        modelContext.insert(item)
        dismiss()
    }
}

#Preview {
    MovementLibraryView()
        .modelContainer(for: MovementLibraryItem.self, inMemory: true)
}
