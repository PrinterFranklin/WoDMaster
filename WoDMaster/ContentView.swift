//
//  ContentView.swift
//  WoDMaster
//
//  Created by 张天行 on 2026/3/2.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [WOD.self, PersonalRecord.self, WorkoutResult.self, UserProfile.self], inMemory: true)
}
