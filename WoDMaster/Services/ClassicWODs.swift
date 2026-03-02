//
//  ClassicWODs.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation

// MARK: - Classic / Benchmark WODs Factory
struct ClassicWODs {
    
    static func allClassicWODs() -> [WOD] {
        return [fran(), murph(), grace(), diane(), helen(),
                cindy(), annie(), jackie(), elizabeth(), isabel(),
                karen(), filthy50()]
    }
    
    // MARK: - "The Girls"
    
    static func fran() -> WOD {
        let movements = [
            WODMovement(movementName: "Thruster", reps: 21, weight: 43, order: 0),
            WODMovement(movementName: "Pull-up", reps: 21, order: 1),
            WODMovement(movementName: "Thruster", reps: 15, weight: 43, order: 2),
            WODMovement(movementName: "Pull-up", reps: 15, order: 3),
            WODMovement(movementName: "Thruster", reps: 9, weight: 43, order: 4),
            WODMovement(movementName: "Pull-up", reps: 9, order: 5),
        ]
        return WOD(name: "Fran", wodType: .forTime, wodDescription: "21-15-9\nThrusters (43kg/30kg)\nPull-ups", timeCap: 600, rounds: 3, movements: movements, isClassic: true)
    }
    
    static func murph() -> WOD {
        let movements = [
            WODMovement(movementName: "Run", reps: 1, distance: 1600, order: 0),
            WODMovement(movementName: "Pull-up", reps: 100, order: 1),
            WODMovement(movementName: "Push-up", reps: 200, order: 2),
            WODMovement(movementName: "Air Squat", reps: 300, order: 3),
            WODMovement(movementName: "Run", reps: 1, distance: 1600, order: 4),
        ]
        return WOD(name: "Murph", wodType: .forTime, wodDescription: "1 mile Run\n100 Pull-ups\n200 Push-ups\n300 Air Squats\n1 mile Run\n*With a 20/14 lb vest", movements: movements, isClassic: true)
    }
    
    static func grace() -> WOD {
        let movements = [
            WODMovement(movementName: "Clean & Jerk", reps: 30, weight: 61, order: 0),
        ]
        return WOD(name: "Grace", wodType: .forTime, wodDescription: "30 Clean & Jerks (61kg/43kg)", timeCap: 600, movements: movements, isClassic: true)
    }
    
    static func diane() -> WOD {
        let movements = [
            WODMovement(movementName: "Deadlift", reps: 21, weight: 102, order: 0),
            WODMovement(movementName: "Handstand Push-up", reps: 21, order: 1),
            WODMovement(movementName: "Deadlift", reps: 15, weight: 102, order: 2),
            WODMovement(movementName: "Handstand Push-up", reps: 15, order: 3),
            WODMovement(movementName: "Deadlift", reps: 9, weight: 102, order: 4),
            WODMovement(movementName: "Handstand Push-up", reps: 9, order: 5),
        ]
        return WOD(name: "Diane", wodType: .forTime, wodDescription: "21-15-9\nDeadlifts (102kg/70kg)\nHandstand Push-ups", timeCap: 600, rounds: 3, movements: movements, isClassic: true)
    }
    
    static func helen() -> WOD {
        let movements = [
            WODMovement(movementName: "Run", reps: 1, distance: 400, order: 0),
            WODMovement(movementName: "Kettlebell Swing", reps: 21, weight: 24, order: 1),
            WODMovement(movementName: "Pull-up", reps: 12, order: 2),
        ]
        return WOD(name: "Helen", wodType: .forTime, wodDescription: "3 Rounds:\n400m Run\n21 KB Swings (24kg/16kg)\n12 Pull-ups", rounds: 3, movements: movements, isClassic: true)
    }
    
    static func cindy() -> WOD {
        let movements = [
            WODMovement(movementName: "Pull-up", reps: 5, order: 0),
            WODMovement(movementName: "Push-up", reps: 10, order: 1),
            WODMovement(movementName: "Air Squat", reps: 15, order: 2),
        ]
        return WOD(name: "Cindy", wodType: .amrap, wodDescription: "20 min AMRAP:\n5 Pull-ups\n10 Push-ups\n15 Air Squats", timeCap: 1200, movements: movements, isClassic: true)
    }
    
    static func annie() -> WOD {
        let movements = [
            WODMovement(movementName: "Double Under", reps: 50, order: 0),
            WODMovement(movementName: "Sit-up", reps: 50, order: 1),
            WODMovement(movementName: "Double Under", reps: 40, order: 2),
            WODMovement(movementName: "Sit-up", reps: 40, order: 3),
            WODMovement(movementName: "Double Under", reps: 30, order: 4),
            WODMovement(movementName: "Sit-up", reps: 30, order: 5),
            WODMovement(movementName: "Double Under", reps: 20, order: 6),
            WODMovement(movementName: "Sit-up", reps: 20, order: 7),
            WODMovement(movementName: "Double Under", reps: 10, order: 8),
            WODMovement(movementName: "Sit-up", reps: 10, order: 9),
        ]
        return WOD(name: "Annie", wodType: .forTime, wodDescription: "50-40-30-20-10\nDouble Unders\nSit-ups", rounds: 5, movements: movements, isClassic: true)
    }
    
    static func jackie() -> WOD {
        let movements = [
            WODMovement(movementName: "Row", reps: 1, calories: 0, order: 0), // 1000m row
            WODMovement(movementName: "Thruster", reps: 50, weight: 20, order: 1),
            WODMovement(movementName: "Pull-up", reps: 30, order: 2),
        ]
        return WOD(name: "Jackie", wodType: .forTime, wodDescription: "1000m Row\n50 Thrusters (20kg/15kg)\n30 Pull-ups", movements: movements, isClassic: true)
    }
    
    static func elizabeth() -> WOD {
        let movements = [
            WODMovement(movementName: "Clean", reps: 21, weight: 61, order: 0),
            WODMovement(movementName: "Ring Dip", reps: 21, order: 1),
            WODMovement(movementName: "Clean", reps: 15, weight: 61, order: 2),
            WODMovement(movementName: "Ring Dip", reps: 15, order: 3),
            WODMovement(movementName: "Clean", reps: 9, weight: 61, order: 4),
            WODMovement(movementName: "Ring Dip", reps: 9, order: 5),
        ]
        return WOD(name: "Elizabeth", wodType: .forTime, wodDescription: "21-15-9\nCleans (61kg/43kg)\nRing Dips", rounds: 3, movements: movements, isClassic: true)
    }
    
    static func isabel() -> WOD {
        let movements = [
            WODMovement(movementName: "Snatch", reps: 30, weight: 61, order: 0),
        ]
        return WOD(name: "Isabel", wodType: .forTime, wodDescription: "30 Snatches (61kg/43kg)", timeCap: 600, movements: movements, isClassic: true)
    }
    
    static func karen() -> WOD {
        let movements = [
            WODMovement(movementName: "Wall Ball", reps: 150, weight: 9, order: 0),
        ]
        return WOD(name: "Karen", wodType: .forTime, wodDescription: "150 Wall Balls (9kg/6kg)", movements: movements, isClassic: true)
    }
    
    static func filthy50() -> WOD {
        let movements = [
            WODMovement(movementName: "Box Jump", reps: 50, order: 0),
            WODMovement(movementName: "Jumping Pull-up", reps: 50, order: 1),
            WODMovement(movementName: "Kettlebell Swing", reps: 50, weight: 16, order: 2),
            WODMovement(movementName: "Walking Lunge", reps: 50, order: 3),
            WODMovement(movementName: "Knees to Elbow", reps: 50, order: 4),
            WODMovement(movementName: "Push Press", reps: 50, weight: 20, order: 5),
            WODMovement(movementName: "Back Extension", reps: 50, order: 6),
            WODMovement(movementName: "Wall Ball", reps: 50, weight: 9, order: 7),
            WODMovement(movementName: "Burpee", reps: 50, order: 8),
            WODMovement(movementName: "Double Under", reps: 50, order: 9),
        ]
        return WOD(name: "Filthy Fifty", wodType: .chipper, wodDescription: "50 of each:\nBox Jumps, Jumping Pull-ups, KB Swings, Walking Lunges, K2E, Push Press, Back Extensions, Wall Balls, Burpees, Double Unders", movements: movements, isClassic: true)
    }
}
