//
//  AddPRView.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import SwiftUI
import SwiftData

struct AddPRView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \MovementLibraryItem.name) private var movements: [MovementLibraryItem]
    @Query private var profiles: [UserProfile]
    
    @State private var selectedMovement: MovementLibraryItem?
    @State private var selectedPRType: PRType?
    @State private var value: Double = 0
    @State private var date = Date()
    @State private var notes = ""
    @State private var showingMovementPicker = false
    
    var weightUnit: WeightUnit { profiles.first?.preferredWeightUnit ?? .kg }
    
    /// Filtered PR types based on the selected movement's allowed types
    var availablePRTypes: [PRType] {
        guard let movement = selectedMovement else { return PRType.allCases.filter { _ in true } }
        return movement.allowedPRTypes.compactMap { PRType.from($0) }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Movement selection
                Section("Movement") {
                    Button(action: { showingMovementPicker = true }) {
                        HStack {
                            if let movement = selectedMovement {
                                Image(systemName: movement.icon)
                                    .foregroundColor(.orange)
                                Text(movement.name)
                                    .foregroundColor(.primary)
                            } else {
                                Image(systemName: "figure.cross.training")
                                    .foregroundColor(.secondary)
                                Text("Select Movement")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // PR Type — only show types allowed for the selected movement
                if selectedMovement != nil {
                    Section("Record Type") {
                        if availablePRTypes.count <= 4 {
                            Picker("PR Type", selection: $selectedPRType) {
                                ForEach(availablePRTypes) { type in
                                    Text(type.rawValue).tag(Optional(type))
                                }
                            }
                            .pickerStyle(.segmented)
                        } else {
                            ForEach(availablePRTypes) { type in
                                Button(action: { selectedPRType = type }) {
                                    HStack {
                                        Text(type.rawValue)
                                        Spacer()
                                        if selectedPRType == type {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.orange)
                                        }
                                    }
                                }
                                .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                // Value input
                if let prType = selectedPRType {
                    Section(valueLabel(for: prType)) {
                        HStack {
                            TextField("Value", value: $value, format: .number)
                                .keyboardType(.decimalPad)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(prType.unitString(weightUnit: weightUnit))
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        // Quick adjust buttons
                        HStack(spacing: 12) {
                            ForEach(quickAdjustValues(for: prType), id: \.self) { adj in
                                Button(action: { value = max(0, value + adj) }) {
                                    Text(adj > 0 ? "+\(formatAdj(adj))" : "\(formatAdj(adj))")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Section("Details") {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        TextField("Notes (optional)", text: $notes, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    
                    // Preview
                    Section("Preview") {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(selectedMovement?.name ?? "")
                                    .font(.headline)
                                Text(prType.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(previewValue)
                                .font(.title)
                                .fontWeight(.black)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .navigationTitle("New PR 🎉")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { savePR() }
                        .disabled(selectedMovement == nil || selectedPRType == nil || value <= 0)
                        .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingMovementPicker) {
                MovementPickerView(selectedMovement: $selectedMovement) {
                    // When movement changes, reset PR type to first available
                    if let first = availablePRTypes.first {
                        selectedPRType = first
                    } else {
                        selectedPRType = nil
                    }
                    value = 0
                }
            }
            .onChange(of: selectedMovement) { _, _ in
                // Auto-select first available PR type
                if let first = availablePRTypes.first, selectedPRType == nil || !availablePRTypes.contains(where: { $0 == selectedPRType }) {
                    selectedPRType = first
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func valueLabel(for prType: PRType) -> String {
        switch prType {
        case .oneRM, .threeRM, .fiveRM: return "Weight"
        case .bestTime, .maxDuration: return "Time (seconds)"
        case .maxDistance: return "Distance (meters)"
        case .maxCalories: return "Calories"
        case .maxReps: return "Reps"
        }
    }
    
    func quickAdjustValues(for prType: PRType) -> [Double] {
        switch prType {
        case .oneRM, .threeRM, .fiveRM:
            if weightUnit == .lb {
                return [-10, -5, 5, 10, 25, 45]
            }
            return [-10, -5, -2.5, 2.5, 5, 10]
        case .bestTime, .maxDuration:
            return [-30, -10, -5, 5, 10, 30]
        case .maxDistance:
            return [-100, -50, -10, 10, 50, 100]
        case .maxCalories:
            return [-10, -5, -1, 1, 5, 10]
        case .maxReps:
            return [-5, -3, -1, 1, 3, 5]
        }
    }
    
    var previewValue: String {
        guard let prType = selectedPRType else { return "" }
        if prType.isWeightBased {
            let kgValue = weightUnit.toKg(value)
            let pr = PersonalRecord(movementName: selectedMovement?.name ?? "", prType: prType, value: kgValue)
            return pr.displayValue(unit: weightUnit)
        }
        let pr = PersonalRecord(movementName: selectedMovement?.name ?? "", prType: prType, value: value)
        return pr.displayValue(unit: weightUnit)
    }
    
    func formatAdj(_ val: Double) -> String {
        if val == val.rounded() {
            return "\(Int(val))"
        }
        return String(format: "%.1f", val)
    }
    
    func savePR() {
        guard let movement = selectedMovement, let prType = selectedPRType else { return }
        // Convert displayed value to kg for storage if weight-based
        let storedValue = prType.isWeightBased ? weightUnit.toKg(value) : value
        let pr = PersonalRecord(
            movementName: movement.name,
            prType: prType,
            value: storedValue,
            date: date,
            notes: notes
        )
        modelContext.insert(pr)
        dismiss()
    }
}

// MARK: - Movement Picker View (reusable)
struct MovementPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \MovementLibraryItem.name) private var movements: [MovementLibraryItem]
    
    @Binding var selectedMovement: MovementLibraryItem?
    var onSelect: (() -> Void)?
    
    @State private var searchText = ""
    @State private var selectedCategory: MovementCategory?
    
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
            List {
                // Category filter
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            chipButton(nil, label: "All")
                            ForEach(MovementCategory.allCases) { cat in
                                chipButton(cat, label: cat.rawValue)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                ForEach(groupedMovements, id: \.0) { category, items in
                    Section(category.rawValue) {
                        ForEach(items) { item in
                            Button(action: {
                                selectedMovement = item
                                onSelect?()
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: item.icon)
                                        .foregroundColor(.orange)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.name)
                                            .foregroundColor(.primary)
                                        
                                        HStack(spacing: 4) {
                                            ForEach(item.propertyTags, id: \.self) { tag in
                                                Text(tag)
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedMovement?.id == item.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search movements...")
            .navigationTitle("Select Movement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    func chipButton(_ category: MovementCategory?, label: String) -> some View {
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
}

#Preview {
    AddPRView()
        .modelContainer(for: [PersonalRecord.self, UserProfile.self, MovementLibraryItem.self], inMemory: true)
}
