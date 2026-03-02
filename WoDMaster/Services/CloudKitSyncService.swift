//
//  CloudKitSyncService.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation
import CloudKit
import SwiftData

// MARK: - CloudKit Record Types
/// Record type names in the CloudKit Public Database.
/// These must match exactly what you create in CloudKit Dashboard.
enum CKRecordTypes {
    static let remoteMovement = "RemoteMovement"
    static let remoteWOD = "RemoteWOD"
    static let remoteWODMovement = "RemoteWODMovement"
}

// MARK: - CloudKit Sync Service
/// Service responsible for fetching new movements and WoDs from CloudKit Public Database.
/// Content is pushed via CloudKit Dashboard or a companion admin tool.
///
/// Architecture:
/// - Public Database: shared content (movements, benchmark WoDs) — free, no auth required
/// - Private Database: user data (PR records, workout results) — synced via iCloud
///
/// Note: If CloudKit is not configured (no container identifier set), the service
/// gracefully skips sync and the app runs in local-only mode.
actor CloudKitSyncService {
    
    static let shared = CloudKitSyncService()
    
    // MARK: - Configuration
    
    /// Set this to your actual CloudKit container identifier.
    /// When the value is empty or the placeholder, sync will be skipped.
    /// To configure: Xcode → Target → Signing & Capabilities → + CloudKit → Containers → +
    static var containerIdentifier: String = "iCloud.com.wodmaster.WoDMaster"
    
    /// Placeholder value — when the identifier equals this, CloudKit is considered unconfigured.
    private static let placeholderIdentifier = "iCloud.com.wodmaster.WoDMaster"
    
    /// Whether CloudKit sync is enabled.
    /// Returns false if the container identifier is not configured or sync is explicitly disabled.
    var isEnabled: Bool {
        let id = Self.containerIdentifier
        // Not configured if empty, placeholder, or explicitly disabled
        if id.isEmpty || id == Self.placeholderIdentifier {
            return false
        }
        return UserDefaults.standard.bool(forKey: "CloudKit.SyncEnabled") != false
            || UserDefaults.standard.object(forKey: "CloudKit.SyncEnabled") == nil
    }
    
    private var container: CKContainer {
        CKContainer(identifier: Self.containerIdentifier)
    }
    
    private var publicDB: CKDatabase {
        container.publicCloudDatabase
    }
    
    // MARK: - Version Tracking
    private let movementVersionKey = "CloudKit.MovementVersion"
    private let wodVersionKey = "CloudKit.WODVersion"
    private let lastSyncKey = "CloudKit.LastSyncDate"
    
    private var lastMovementVersion: String {
        get { UserDefaults.standard.string(forKey: movementVersionKey) ?? "0" }
        set { UserDefaults.standard.set(newValue, forKey: movementVersionKey) }
    }
    
    private var lastWODVersion: String {
        get { UserDefaults.standard.string(forKey: wodVersionKey) ?? "0" }
        set { UserDefaults.standard.set(newValue, forKey: wodVersionKey) }
    }
    
    // MARK: - Public API
    
    /// Perform a full sync: fetch new movements and WoDs from CloudKit Public Database.
    /// Safe to call on every app launch — it only fetches records newer than the last known version.
    /// Gracefully skips if CloudKit is not configured or iCloud is unavailable.
    func syncAll(modelContext: ModelContext) async {
        // Skip sync if CloudKit is not configured
        guard isEnabled else {
            print("☁️ [CloudKit] Sync disabled — container identifier not configured. Running in local-only mode.")
            return
        }
        
        // Verify iCloud account is available
        do {
            let status = try await container.accountStatus()
            guard status == .available else {
                let statusName: String
                switch status {
                case .couldNotDetermine: statusName = "couldNotDetermine"
                case .restricted: statusName = "restricted"
                case .noAccount: statusName = "noAccount"
                case .temporarilyUnavailable: statusName = "temporarilyUnavailable"
                default: statusName = "unknown"
                }
                print("☁️ [CloudKit] iCloud account not available (status: \(statusName)). Skipping sync.")
                return
            }
        } catch {
            print("☁️ [CloudKit] Cannot check iCloud account status: \(error.localizedDescription). Skipping sync.")
            return
        }
        
        print("☁️ [CloudKit] Starting sync...")
        
        // Sync movements and WoDs concurrently
        async let movementResult: () = syncMovements(modelContext: modelContext)
        async let wodResult: () = syncWODs(modelContext: modelContext)
        
        await movementResult
        await wodResult
        
        UserDefaults.standard.set(Date(), forKey: lastSyncKey)
        print("☁️ [CloudKit] Sync complete.")
    }
    
    // MARK: - Movement Sync
    
    /// Fetch new movements from CloudKit that are newer than our last known version.
    private func syncMovements(modelContext: ModelContext) async {
        let predicate = NSPredicate(format: "version > %@", lastMovementVersion)
        let query = CKQuery(recordType: CKRecordTypes.remoteMovement, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "version", ascending: true)]
        
        do {
            let (results, _) = try await publicDB.records(matching: query, resultsLimit: 200)
            
            // Get existing movement names to avoid duplicates
            let descriptor = FetchDescriptor<MovementLibraryItem>()
            let existingNames = Set((try? modelContext.fetch(descriptor))?.map(\.name) ?? [])
            
            var latestVersion = lastMovementVersion
            var insertedCount = 0
            
            for (_, result) in results {
                guard let record = try? result.get() else { continue }
                let name = record["name"] as? String ?? ""
                
                guard !name.isEmpty, !existingNames.contains(name) else { continue }
                
                let categoryStr = record["category"] as? String ?? "Gym"
                let tagsStr = record["tags"] as? [String] ?? []
                let prTypesStr = record["allowedPRTypes"] as? [String] ?? []
                
                let cat = MovementCategory(rawValue: categoryStr) ?? .gym
                let tags = tagsStr.compactMap { MovementTag(rawValue: $0) }
                let prTypes = prTypesStr.compactMap { AllowedPRType(rawValue: $0) }
                
                let item = MovementLibraryItem(
                    name: name,
                    category: cat,
                    isDefault: true,
                    tags: tags,
                    hasWeight: record["hasWeight"] as? Bool ?? false,
                    hasDistance: record["hasDistance"] as? Bool ?? false,
                    hasCalories: record["hasCalories"] as? Bool ?? false,
                    hasTime: record["hasTime"] as? Bool ?? false,
                    allowedPRTypes: prTypes,
                    defaultRxWeightMale: record["defaultRxWeightMale"] as? Double,
                    defaultRxWeightFemale: record["defaultRxWeightFemale"] as? Double
                )
                modelContext.insert(item)
                insertedCount += 1
                
                if let v = record["version"] as? String, v > latestVersion {
                    latestVersion = v
                }
            }
            
            if insertedCount > 0 {
                try? modelContext.save()
                lastMovementVersion = latestVersion
                print("☁️ [CloudKit] Synced \(insertedCount) new movements (version: \(latestVersion))")
            } else {
                print("☁️ [CloudKit] No new movements to sync.")
            }
            
        } catch {
            print("☁️ [CloudKit] Movement sync error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - WOD Sync
    
    /// Fetch new WoDs from CloudKit that are newer than our last known version.
    private func syncWODs(modelContext: ModelContext) async {
        let predicate = NSPredicate(format: "version > %@", lastWODVersion)
        let query = CKQuery(recordType: CKRecordTypes.remoteWOD, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "version", ascending: true)]
        
        do {
            let (results, _) = try await publicDB.records(matching: query, resultsLimit: 100)
            
            // Get existing WOD names
            let descriptor = FetchDescriptor<WOD>()
            let existingNames = Set((try? modelContext.fetch(descriptor))?.map(\.name) ?? [])
            
            // Get existing movement names for validation
            let movementDescriptor = FetchDescriptor<MovementLibraryItem>()
            let knownMovements = Set((try? modelContext.fetch(movementDescriptor))?.map(\.name) ?? [])
            
            var latestVersion = lastWODVersion
            var insertedCount = 0
            
            for (_, result) in results {
                guard let record = try? result.get() else { continue }
                let name = record["name"] as? String ?? ""
                
                guard !name.isEmpty, !existingNames.contains(name) else { continue }
                
                let wodTypeStr = record["wodType"] as? String ?? "For Time"
                let description = record["wodDescription"] as? String ?? ""
                let timeCap = record["timeCap"] as? Int
                let rounds = record["rounds"] as? Int
                let emomInterval = record["emomInterval"] as? Int
                
                // Parse movements from a JSON string stored in CloudKit
                let movementsJSON = record["movementsJSON"] as? String ?? "[]"
                let movements = parseWODMovements(from: movementsJSON)
                
                // Validate that movements exist in library
                let missingMovements = movements.filter { !knownMovements.contains($0.movementName) }
                if !missingMovements.isEmpty {
                    print("☁️ [CloudKit] WOD '\(name)' references unknown movements: \(missingMovements.map(\.movementName))")
                }
                
                let wodType = WODType(rawValue: wodTypeStr) ?? .forTime
                let wod = WOD(
                    name: name,
                    wodType: wodType,
                    wodDescription: description,
                    timeCap: timeCap,
                    rounds: rounds,
                    emomInterval: emomInterval,
                    movements: movements,
                    isBenchmark: true
                )
                modelContext.insert(wod)
                insertedCount += 1
                
                if let v = record["version"] as? String, v > latestVersion {
                    latestVersion = v
                }
            }
            
            if insertedCount > 0 {
                try? modelContext.save()
                lastWODVersion = latestVersion
                print("☁️ [CloudKit] Synced \(insertedCount) new WODs (version: \(latestVersion))")
            } else {
                print("☁️ [CloudKit] No new WODs to sync.")
            }
            
        } catch {
            print("☁️ [CloudKit] WOD sync error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers
    
    /// Parse WOD movements from a JSON string (stored as a single field in CloudKit).
    /// JSON format: [{"movementName":"Thruster","reps":21,"weight":43,"order":0}, ...]
    private func parseWODMovements(from json: String) -> [WODMovement] {
        guard let data = json.data(using: .utf8) else { return [] }
        
        struct WODMovementDTO: Codable {
            let movementName: String
            let reps: Int
            let weight: Double?
            let distance: Double?
            let calories: Int?
            let order: Int
        }
        
        do {
            let dtos = try JSONDecoder().decode([WODMovementDTO].self, from: data)
            return dtos.map { dto in
                WODMovement(
                    movementName: dto.movementName,
                    reps: dto.reps,
                    weight: dto.weight,
                    distance: dto.distance,
                    calories: dto.calories,
                    order: dto.order
                )
            }
        } catch {
            print("☁️ [CloudKit] Failed to parse WOD movements JSON: \(error)")
            return []
        }
    }
    
    /// Get the last sync date for display in the UI.
    var lastSyncDate: Date? {
        UserDefaults.standard.object(forKey: lastSyncKey) as? Date
    }
    
    /// Get a human-readable sync status.
    var syncStatus: String {
        if let date = lastSyncDate {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return "Last sync: \(formatter.localizedString(for: date, relativeTo: Date()))"
        }
        return "Never synced"
    }
}
