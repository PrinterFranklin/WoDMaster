//
//  ProfileView.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var results: [WorkoutResult]
    @Query private var prs: [PersonalRecord]
    
    var profile: UserProfile? { profiles.first }
    
    @State private var isEditing = false
    @State private var editName = ""
    @State private var editGender: Gender = .male
    @State private var editBodyWeight: Double = 75.0
    @State private var editHeight: Double = 175.0
    @State private var editFitnessLevel: FitnessLevel = .intermediate
    @State private var editBoxName = ""
    @State private var editWeightUnit: WeightUnit = .kg
    
    var weightUnit: WeightUnit { profile?.preferredWeightUnit ?? .kg }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Avatar & Name
                    profileHeader
                    
                    // Stats Dashboard
                    statsDashboard
                    
                    // Profile Details
                    profileDetails
                    
                    // Top PRs
                    topPRsSection
                }
                .padding()
            }
            .navigationTitle("Profile 👤")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            saveProfile()
                        } else {
                            startEditing()
                        }
                        isEditing.toggle()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    // MARK: - Profile Header
    var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 100, height: 100)
                
                Text(avatarInitials)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            
            if isEditing {
                TextField("Name", text: $editName)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 200)
            } else {
                Text(profile?.name.isEmpty == false ? profile!.name : "Athlete")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            if let p = profile {
                Text(p.fitnessLevel.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(levelColor(p.fitnessLevel).opacity(0.2))
                    )
                    .foregroundColor(levelColor(p.fitnessLevel))
            }
        }
    }
    
    var avatarInitials: String {
        let name = profile?.name ?? "A"
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
    
    // MARK: - Stats Dashboard
    var statsDashboard: some View {
        HStack(spacing: 16) {
            dashboardItem(title: "Workouts", value: "\(results.count)", icon: "flame.fill", color: .orange)
            dashboardItem(title: "PRs", value: "\(prs.count)", icon: "trophy.fill", color: .yellow)
            dashboardItem(title: "This Week", value: "\(thisWeekCount)", icon: "calendar", color: .blue)
        }
    }
    
    var thisWeekCount: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return results.filter { $0.date >= startOfWeek }.count
    }
    
    func dashboardItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.black)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Profile Details
    var profileDetails: some View {
        VStack(spacing: 12) {
            if isEditing {
                editingView
            } else {
                detailsView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    var detailsView: some View {
        VStack(spacing: 12) {
            detailRow(label: "Gender", value: profile?.gender.rawValue ?? "-")
            detailRow(label: "Body Weight", value: weightUnit.displayString(profile?.bodyWeight ?? 0))
            detailRow(label: "Height", value: "\(Int(profile?.height ?? 0)) cm")
            detailRow(label: "Box", value: profile?.boxName.isEmpty == false ? profile!.boxName : "Not set")
            detailRow(label: "Level", value: profile?.fitnessLevel.rawValue ?? "-")
            detailRow(label: "Weight Unit", value: weightUnit.rawValue.uppercased())
        }
    }
    
    var editingView: some View {
        VStack(spacing: 16) {
            Picker("Gender", selection: $editGender) {
                ForEach(Gender.allCases) { g in
                    Text(g.rawValue).tag(g)
                }
            }
            .pickerStyle(.segmented)
            
            // Weight Unit Picker
            HStack {
                Text("Weight Unit")
                    .foregroundColor(.secondary)
                Spacer()
                Picker("Unit", selection: $editWeightUnit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.rawValue.uppercased()).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
            
            HStack {
                Text("Body Weight")
                    .foregroundColor(.secondary)
                Spacer()
                TextField(editWeightUnit.rawValue, value: $editBodyWeight, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                Text(editWeightUnit.rawValue)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Height")
                    .foregroundColor(.secondary)
                Spacer()
                TextField("cm", value: $editHeight, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                Text("cm")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Box Name")
                    .foregroundColor(.secondary)
                Spacer()
                TextField("CrossFit Box", text: $editBoxName)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 180)
            }
            
            Picker("Fitness Level", selection: $editFitnessLevel) {
                ForEach(FitnessLevel.allCases) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Top PRs
    var topPRsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top PRs")
                .font(.title3)
                .fontWeight(.bold)
            
            if prs.isEmpty {
                Text("No PRs recorded yet")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else {
                // Show best PR for each movement (max 5)
                let topPRs = getTopPRs()
                ForEach(topPRs) { pr in
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pr.movementName)
                                .font(.body)
                            Text(pr.prType.rawValue)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(pr.displayValue(unit: weightUnit))
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    func getTopPRs() -> [PersonalRecord] {
        let weightPRs = prs.filter { $0.prType.isWeightBased }
        let grouped = Dictionary(grouping: weightPRs) { $0.movementName }
        return grouped.compactMap { _, records in
            records.max(by: { $0.value < $1.value })
        }
        .sorted { $0.value > $1.value }
        .prefix(5)
        .map { $0 }
    }
    
    func levelColor(_ level: FitnessLevel) -> Color {
        switch level {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .purple
        case .elite: return .red
        }
    }
    
    // MARK: - Edit Actions
    func startEditing() {
        guard let p = profile else { return }
        editName = p.name
        editGender = p.gender
        editWeightUnit = p.preferredWeightUnit
        // Show body weight in user's preferred unit
        editBodyWeight = p.preferredWeightUnit.fromKg(p.bodyWeight)
        editHeight = p.height
        editFitnessLevel = p.fitnessLevel
        editBoxName = p.boxName
    }
    
    func saveProfile() {
        guard let p = profile else { return }
        p.name = editName
        p.gender = editGender
        p.weightUnit = editWeightUnit
        // Convert body weight back to kg for storage
        p.bodyWeight = editWeightUnit.toKg(editBodyWeight)
        p.height = editHeight
        p.fitnessLevel = editFitnessLevel
        p.boxName = editBoxName
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [UserProfile.self, WorkoutResult.self, PersonalRecord.self], inMemory: true)
}
