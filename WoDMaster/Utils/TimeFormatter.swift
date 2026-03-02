//
//  TimeFormatter.swift
//  WoDMaster
//
//  Created by WoDMaster on 2026/3/2.
//

import Foundation

struct TimeFormatter {
    static func format(seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        let hundredths = Int((seconds - Double(totalSeconds)) * 100)
        
        if mins > 0 {
            return String(format: "%d:%02d.%02d", mins, secs, hundredths)
        } else {
            return String(format: "%d.%02d", secs, hundredths)
        }
    }
    
    static func formatShort(seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let mins = totalSeconds / 60
        let secs = totalSeconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    static func formatLong(seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let mins = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, mins, secs)
        } else {
            return String(format: "%d:%02d", mins, secs)
        }
    }
}
