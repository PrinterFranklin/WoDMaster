//
//  AddWODView.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import SwiftUI
import SwiftData

struct AddWODView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @Query(sort: \MovementLibraryItem.name) private var libraryMovements: [MovementLibraryItem]
    
    /// The WOD being edited; nil means "create new"
    var editingWOD: WOD?
    
    var isEditing: Bool { editingWOD != nil }
    
    @State private var name = ""
    @State private var wodType: WODType = .forTime
    @State private var description = ""
    @State private var timeCap: Int = 10
    @State private var rounds: Int = 3
    @State private var emomInterval: Int = 60
    @State private var movements: [WODMovement] = []
    @State private var showingAddMovement = false
    @State private var editingMovementIndex: Int? = nil
    
    // New / editing movement fields
    @State private var selectedLibraryItem: MovementLibraryItem?
    @State private var newMovementReps = 10
    @State private var newMovementWeight: Double?
    @State private var newMovementWeightUnit: WeightUnit = .kg
    @State private var newMovementDistance: Double?
    @State private var newMovementCalories: Int?
    @State private var showingMovementPicker = false
    
    /// Default unit for new movements comes from user profile
    var defaultWeightUnit: WeightUnit { profiles.first?.preferredWeightUnit ?? .kg }
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic Info
                Section("Basic Info") {
                    TextField("WOD Name", text: $name)
                    
                    Picker("Type", selection: $wodType) {
                        ForEach(WODType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Time Settings
                Section("Settings") {
                    Stepper("Time Cap: \(timeCap) min", value: $timeCap, in: 1...60)
                    
                    if wodType == .forTime || wodType == .amrap {
                        Stepper("Rounds: \(rounds)", value: $rounds, in: 1...50)
                    }
                    
                    if wodType == .emom {
                        Stepper("Interval: \(emomInterval)s", value: $emomInterval, in: 15...300, step: 15)
                    }
                }
                
                // Movements
                Section("Movements") {
                    ForEach(Array(movements.sorted(by: { $0.order < $1.order }).enumerated()), id: \.element.id) { index, movement in
                        HStack {
                            Text("\(movement.order + 1).")
                                .foregroundColor(.secondary)
                            Text(movement.displayString)
                            Spacer()
                            // Edit button for each movement
                            Button(action: { startEditingMovement(at: index) }) {
                                Image(systemName: "pencil.circle")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onDelete(perform: deleteMovement)
                    
                    Button(action: {
                        editingMovementIndex = nil
                        resetNewMovement()
                        showingAddMovement = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.orange)
                            Text("Add Movement")
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit WOD" : "New WOD")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveWOD() }
                        .disabled(name.isEmpty || movements.isEmpty)
                        .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingAddMovement) {
                movementEditorSheet
            }
            .onAppear {
                if let wod = editingWOD {
                    loadWOD(wod)
                }
            }
        }
    }
    
    // MARK: - Movement Editor Sheet
    var movementEditorSheet: some View {
        NavigationStack {
            Form {
                // Step 1: Select movement from library
                Section("Movement") {
                    Button(action: { showingMovementPicker = true }) {
                        HStack {
                            if let item = selectedLibraryItem {
                                Image(systemName: item.icon)
                                    .foregroundColor(.orange)
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
                            } else {
                                Image(systemName: "figure.cross.training")
                                    .foregroundColor(.secondary)
                                Text("Select from Library")
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Stepper("Reps: \(newMovementReps)", value: $newMovementReps, in: 1...500)
                }
                
                // Step 2: Show only applicable fields based on movement properties
                if let item = selectedLibraryItem {
                    // Weight section — only if movement has weight
                    if item.hasWeight {
                        Section("Weight") {
                            Picker("Unit", selection: $newMovementWeightUnit) {
                                ForEach(WeightUnit.allCases) { unit in
                                    Text(unit.rawValue.uppercased()).tag(unit)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            HStack {
                                TextField("Weight", value: $newMovementWeight, format: .number)
                                    .keyboardType(.decimalPad)
                                
                                Text(newMovementWeightUnit.rawValue)
                                    .foregroundColor(.secondary)
                            }
                            
                            if newMovementWeightUnit == .kg {
                                HStack(spacing: 8) {
                                    ForEach([2.5, 5.0, 10.0, 20.0], id: \.self) { inc in
                                        Button("+\(formatWeight(inc))") {
                                            newMovementWeight = (newMovementWeight ?? 0) + inc
                                        }
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(6)
                                        .buttonStyle(.plain)
                                    }
                                }
                            } else {
                                HStack(spacing: 8) {
                                    ForEach([5.0, 10.0, 25.0, 45.0], id: \.self) { inc in
                                        Button("+\(Int(inc))") {
                                            newMovementWeight = (newMovementWeight ?? 0) + inc
                                        }
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray5))
                                        .cornerRadius(6)
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Distance section — only if movement has distance
                    if item.hasDistance {
                        Section("Distance (m)") {
                            HStack {
                                TextField("Distance", value: $newMovementDistance, format: .number)
                                    .keyboardType(.decimalPad)
                                Text("m")
                                    .foregroundColor(.secondary)
                            }
                            
                            // Quick distance buttons
                            HStack(spacing: 8) {
                                ForEach([100.0, 200.0, 400.0, 800.0, 1600.0], id: \.self) { dist in
                                    Button("\(Int(dist))m") {
                                        newMovementDistance = dist
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    
                    // Calories section — only if movement has calories
                    if item.hasCalories {
                        Section("Calories") {
                            HStack {
                                TextField("Calories", value: $newMovementCalories, format: .number)
                                    .keyboardType(.numberPad)
                                Text("cal")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(editingMovementIndex != nil ? "Edit Movement" : "Add Movement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddMovement = false
                        resetNewMovement()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingMovementIndex != nil ? "Update" : "Add") {
                        if editingMovementIndex != nil {
                            updateMovement()
                        } else {
                            addMovement()
                        }
                        showingAddMovement = false
                    }
                    .disabled(selectedLibraryItem == nil)
                    .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingMovementPicker) {
                MovementPickerView(selectedMovement: $selectedLibraryItem) {
                    // Reset values when movement changes
                    newMovementWeight = nil
                    newMovementDistance = nil
                    newMovementCalories = nil
                    newMovementWeightUnit = defaultWeightUnit
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Movement Actions
    
    private func startEditingMovement(at index: Int) {
        let sorted = movements.sorted(by: { $0.order < $1.order })
        guard index < sorted.count else { return }
        let movement = sorted[index]
        editingMovementIndex = index
        // Find the library item by name
        selectedLibraryItem = libraryMovements.first(where: { $0.name == movement.movementName })
        newMovementReps = movement.reps
        newMovementWeightUnit = movement.movementWeightUnit
        newMovementWeight = movement.weight
        newMovementDistance = movement.distance
        newMovementCalories = movement.calories
        showingAddMovement = true
    }
    
    private func addMovement() {
        guard let item = selectedLibraryItem else { return }
        let movement = WODMovement(
            movementName: item.name,
            reps: newMovementReps,
            weight: item.hasWeight ? newMovementWeight : nil,
            weightUnit: newMovementWeightUnit,
            distance: item.hasDistance ? newMovementDistance : nil,
            calories: item.hasCalories ? newMovementCalories : nil,
            order: movements.count
        )
        movements.append(movement)
        resetNewMovement()
    }
    
    private func updateMovement() {
        guard let index = editingMovementIndex else { return }
        guard let item = selectedLibraryItem else { return }
        let sorted = movements.sorted(by: { $0.order < $1.order })
        guard index < sorted.count else { return }
        let movement = sorted[index]
        movement.movementName = item.name
        movement.reps = newMovementReps
        movement.weight = item.hasWeight ? newMovementWeight : nil
        movement.movementWeightUnit = newMovementWeightUnit
        movement.distance = item.hasDistance ? newMovementDistance : nil
        movement.calories = item.hasCalories ? newMovementCalories : nil
        editingMovementIndex = nil
        resetNewMovement()
    }
    
    private func resetNewMovement() {
        selectedLibraryItem = nil
        newMovementReps = 10
        newMovementWeight = nil
        newMovementWeightUnit = defaultWeightUnit
        newMovementDistance = nil
        newMovementCalories = nil
        editingMovementIndex = nil
    }
    
    private func deleteMovement(offsets: IndexSet) {
        let sorted = movements.sorted(by: { $0.order < $1.order })
        let toDelete = offsets.map { sorted[$0] }
        movements.removeAll { m in toDelete.contains(where: { $0.id == m.id }) }
        // Re-order
        for (index, movement) in movements.sorted(by: { $0.order < $1.order }).enumerated() {
            movement.order = index
        }
    }
    
    private func loadWOD(_ wod: WOD) {
        name = wod.name
        wodType = wod.wodType
        description = wod.wodDescription
        timeCap = (wod.timeCap ?? 600) / 60
        rounds = wod.rounds ?? 3
        emomInterval = wod.emomInterval ?? 60
        movements = wod.movements
    }
    
    private func saveWOD() {
        if let wod = editingWOD {
            // Update existing WOD
            wod.name = name
            wod.wodType = wodType
            wod.wodDescription = description
            wod.timeCap = timeCap * 60
            wod.rounds = rounds
            wod.emomInterval = wodType == .emom ? emomInterval : nil
            wod.movements = movements
        } else {
            // Create new WOD
            let wod = WOD(
                name: name,
                wodType: wodType,
                wodDescription: description,
                timeCap: timeCap * 60,
                rounds: rounds,
                emomInterval: wodType == .emom ? emomInterval : nil,
                movements: movements,
                isClassic: false
            )
            modelContext.insert(wod)
        }
        dismiss()
    }
    
    private func formatWeight(_ val: Double) -> String {
        if val == val.rounded() {
            return "\(Int(val))"
        }
        return String(format: "%.1f", val)
    }
}

#Preview {
    AddWODView()
        .modelContainer(for: [WOD.self, UserProfile.self, MovementLibraryItem.self], inMemory: true)
}
