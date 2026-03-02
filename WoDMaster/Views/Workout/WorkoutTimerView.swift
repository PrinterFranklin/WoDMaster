//
//  WorkoutTimerView.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import SwiftUI
import SwiftData

// MARK: - Workout State
enum WorkoutState {
    case ready
    case countdown
    case active
    case rest
    case finished
}

struct WorkoutTimerView: View {
    let wod: WOD
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutState: WorkoutState = .ready
    @State private var elapsedTime: Double = 0
    @State private var countdownValue: Int = 10
    @State private var currentRound: Int = 1
    @State private var splits: [RoundSplit] = []
    @State private var currentSplitStart: Double = 0
    @State private var isResting = false
    @State private var restTimeRemaining: Int = 0
    @State private var timer: Timer?
    @State private var showingResult = false
    @State private var workoutResult: WorkoutResult?
    @State private var targetSplits: [Double] = []
    @State private var targetTotalTime: Double = 0
    
    var totalRounds: Int { wod.rounds ?? 1 }
    
    // Pace status
    var paceStatus: (text: String, color: Color, icon: String) {
        guard currentRound > 1, !targetSplits.isEmpty else {
            return ("Starting...", .gray, "equal.circle.fill")
        }
        
        let targetElapsed = targetSplits.prefix(currentRound - 1).reduce(0, +)
        let diff = elapsedTime - targetElapsed
        
        if abs(diff) < 5 {
            return ("On Pace", .green, "equal.circle.fill")
        } else if diff > 0 {
            return ("\(Int(diff))s Behind", .red, "arrow.down.circle.fill")
        } else {
            return ("\(Int(abs(diff)))s Ahead", .blue, "arrow.up.circle.fill")
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                
                VStack(spacing: 0) {
                    switch workoutState {
                    case .ready:
                        readyView
                    case .countdown:
                        countdownView
                    case .active, .rest:
                        activeWorkoutView
                    case .finished:
                        EmptyView()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        stopTimer()
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingResult) {
                if let result = workoutResult {
                    WorkoutReportView(result: result)
                }
            }
        }
    }
    
    // MARK: - Background
    var backgroundGradient: some View {
        Group {
            switch workoutState {
            case .ready:
                LinearGradient(colors: [.black, .gray.opacity(0.8)], startPoint: .top, endPoint: .bottom)
            case .countdown:
                LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
            case .active:
                LinearGradient(colors: [.black, paceStatus.color.opacity(0.3)], startPoint: .top, endPoint: .bottom)
            case .rest:
                LinearGradient(colors: [.blue.opacity(0.8), .cyan.opacity(0.6)], startPoint: .top, endPoint: .bottom)
            case .finished:
                LinearGradient(colors: [.green.opacity(0.8), .black], startPoint: .top, endPoint: .bottom)
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Ready View
    var readyView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(wod.name)
                .font(.system(size: 42, weight: .black))
                .foregroundColor(.white)
            
            Text(wod.wodType.rawValue)
                .font(.title2)
                .foregroundColor(.orange)
            
            Text(wod.wodDescription)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Target time input
            VStack(spacing: 8) {
                Text("Target Time (optional)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(spacing: 20) {
                    Button(action: { targetTotalTime = max(0, targetTotalTime - 30) }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    Text(TimeFormatter.formatShort(seconds: targetTotalTime))
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(width: 100)
                    
                    Button(action: { targetTotalTime += 30 }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
            }
            
            Spacer()
            
            Button(action: startCountdown) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("3, 2, 1... GO!")
                        .fontWeight(.black)
                }
                .font(.title2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Countdown View
    var countdownView: some View {
        VStack {
            Spacer()
            
            Text("\(countdownValue)")
                .font(.system(size: 150, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .scaleEffect(countdownValue <= 3 ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: countdownValue)
            
            Text(countdownValue == 0 ? "GO!" : "Get Ready")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
    
    // MARK: - Active Workout View
    var activeWorkoutView: some View {
        VStack(spacing: 16) {
            // Timer Display
            Text(TimeFormatter.format(seconds: elapsedTime))
                .font(.system(size: 64, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Pace Indicator
            if targetTotalTime > 0 {
                HStack(spacing: 8) {
                    Image(systemName: paceStatus.icon)
                    Text(paceStatus.text)
                        .fontWeight(.bold)
                }
                .font(.title3)
                .foregroundColor(paceStatus.color)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(paceStatus.color.opacity(0.2))
                )
            }
            
            // Round Info
            HStack {
                VStack {
                    Text("Round")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(currentRound)/\(totalRounds)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if isResting {
                    VStack {
                        Text("Rest")
                            .font(.caption)
                            .foregroundColor(.cyan)
                        Text("\(restTimeRemaining)s")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text("Split")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(TimeFormatter.formatShort(seconds: elapsedTime - currentSplitStart))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 30)
            
            // Splits History
            if !splits.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(splits) { split in
                            VStack(spacing: 4) {
                                Text("R\(split.roundNumber)")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.7))
                                Text(split.durationFormatted)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.15))
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 20) {
                // Rest button
                Button(action: toggleRest) {
                    VStack(spacing: 4) {
                        Image(systemName: isResting ? "play.fill" : "pause.fill")
                            .font(.title2)
                        Text(isResting ? "Resume" : "Rest")
                            .font(.caption)
                    }
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(isResting ? Color.green : Color.blue)
                    )
                    .foregroundColor(.white)
                }
                
                // Split / Next Round button
                if currentRound < totalRounds {
                    Button(action: recordSplit) {
                        VStack(spacing: 4) {
                            Image(systemName: "forward.fill")
                                .font(.title)
                            Text("Next Round")
                                .font(.caption)
                        }
                        .frame(width: 120, height: 120)
                        .background(
                            Circle()
                                .fill(Color.orange)
                        )
                        .foregroundColor(.white)
                    }
                }
                
                // Finish button
                Button(action: finishWorkout) {
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                        Text("Finish")
                            .font(.caption)
                    }
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(Color.red)
                    )
                    .foregroundColor(.white)
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Timer Logic
    
    func startCountdown() {
        countdownValue = 3
        workoutState = .countdown
        
        // Calculate target splits if target time is set
        if targetTotalTime > 0 {
            targetSplits = WorkoutEngine.calculateTargetSplits(for: wod, targetTime: targetTotalTime)
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdownValue > 1 {
                countdownValue -= 1
            } else {
                // Start workout
                stopTimer()
                workoutState = .active
                elapsedTime = 0
                currentSplitStart = 0
                startWorkoutTimer()
            }
        }
    }
    
    func startWorkoutTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if !isResting {
                elapsedTime += 0.01
            } else {
                restTimeRemaining -= (restTimeRemaining > 0 ? 0 : 0) // rest is tracked separately
            }
            
            // Check time cap
            if let timeCap = wod.timeCap, elapsedTime >= Double(timeCap) {
                finishWorkout()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func toggleRest() {
        isResting.toggle()
        if isResting {
            workoutState = .rest
            restTimeRemaining = 60
        } else {
            workoutState = .active
        }
    }
    
    func recordSplit() {
        let splitDuration = elapsedTime - currentSplitStart
        let split = RoundSplit(roundNumber: currentRound, duration: splitDuration)
        splits.append(split)
        currentSplitStart = elapsedTime
        currentRound += 1
    }
    
    func finishWorkout() {
        // Record final split
        let finalSplitDuration = elapsedTime - currentSplitStart
        let finalSplit = RoundSplit(roundNumber: currentRound, duration: finalSplitDuration)
        splits.append(finalSplit)
        
        stopTimer()
        workoutState = .finished
        
        // Create workout result
        let result: WorkoutResult
        if wod.wodType == .amrap {
            result = WorkoutResult(
                wod: wod,
                wodName: wod.name,
                totalRounds: currentRound,
                extraReps: 0,
                splits: splits
            )
        } else {
            result = WorkoutResult(
                wod: wod,
                wodName: wod.name,
                totalTime: elapsedTime,
                splits: splits
            )
        }
        
        modelContext.insert(result)
        workoutResult = result
        showingResult = true
    }
}

#Preview {
    WorkoutTimerView(wod: ClassicWODs.fran())
        .modelContainer(for: [WOD.self, WorkoutResult.self], inMemory: true)
}
