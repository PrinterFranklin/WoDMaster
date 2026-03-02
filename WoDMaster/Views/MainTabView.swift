//
//  MainTabView.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            WODListView()
                .tabItem {
                    Label("WODs", systemImage: "flame.fill")
                }
            
            PRListView()
                .tabItem {
                    Label("PRs", systemImage: "trophy.fill")
                }
            
            MovementLibraryView()
                .tabItem {
                    Label("Movements", systemImage: "figure.cross.training")
                }
            
            WorkoutHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(.orange)
        .onAppear {
            DataSeeder.seedMovementLibrary(context: modelContext)
            DataSeeder.seedBenchmarkWODs(context: modelContext)
            DataSeeder.seedDefaultProfile(context: modelContext)
        }
        .task {
            // Fetch new content from CloudKit Public Database in the background
            await CloudKitSyncService.shared.syncAll(modelContext: modelContext)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [WOD.self, PersonalRecord.self, WorkoutResult.self, UserProfile.self], inMemory: true)
}
