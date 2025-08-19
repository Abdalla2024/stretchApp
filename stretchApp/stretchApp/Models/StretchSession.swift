//
//  StretchSession.swift
//  stretchApp
//
//  Created by Claude on 8/9/25.
//

import Foundation
import SwiftData

@Model
final class StretchSession {
    /// Unique identifier for the session
    @Attribute(.unique) var id: UUID
    
    /// The category being stretched in this session
    var category: StretchCategory?
    
    /// Whether this session is currently active
    var isActive: Bool
    
    /// Current exercise index in the session
    var currentExerciseIndex: Int
    
    /// Total exercises completed in this session
    var exercisesCompleted: Int
    
    /// Total time spent stretching in this session (seconds)
    var totalStretchTime: Int
    
    /// Session start time
    var startedAt: Date
    
    /// Session end time (when completed)
    var endedAt: Date?
    
    /// Whether the session was completed successfully
    var wasCompleted: Bool
    
    /// Creation date
    var createdAt: Date
    
    /// Last update date
    var updatedAt: Date
    
    init(category: StretchCategory? = nil) {
        self.id = UUID()
        self.category = category
        self.isActive = true
        self.currentExerciseIndex = 0
        self.exercisesCompleted = 0
        self.totalStretchTime = 0
        self.startedAt = Date()
        self.endedAt = nil
        self.wasCompleted = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Mark session as completed
    func completeSession() {
        self.isActive = false
        self.endedAt = Date()
        self.wasCompleted = true
        self.updatedAt = Date()
    }
    
    /// Move to next exercise
    func nextExercise() {
        self.currentExerciseIndex += 1
        self.exercisesCompleted += 1
        self.updatedAt = Date()
    }
    
    /// Move to previous exercise
    func previousExercise() {
        if self.currentExerciseIndex > 0 {
            self.currentExerciseIndex -= 1
            self.updatedAt = Date()
        }
    }
    
    /// Add time to total stretch time
    func addStretchTime(_ seconds: Int) {
        self.totalStretchTime += seconds
        self.updatedAt = Date()
    }
    
    /// Reset session for new use
    func resetSession() {
        self.isActive = true
        self.currentExerciseIndex = 0
        self.exercisesCompleted = 0
        self.totalStretchTime = 0
        self.startedAt = Date()
        self.endedAt = nil
        self.wasCompleted = false
        self.updatedAt = Date()
    }
    
    /// Get session duration
    var sessionDuration: TimeInterval {
        if let endedAt = endedAt {
            return endedAt.timeIntervalSince(startedAt)
        } else {
            return Date().timeIntervalSince(startedAt)
        }
    }
    
    /// Get formatted session duration
    var formattedDuration: String {
        let duration = Int(sessionDuration)
        let minutes = duration / 60
        let seconds = duration % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    /// Get formatted total stretch time
    var formattedTotalStretchTime: String {
        let minutes = totalStretchTime / 60
        let seconds = totalStretchTime % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - Validation Extensions
extension StretchSession {
    /// Validates session data integrity
    var isValid: Bool {
        category != nil && 
        currentExerciseIndex >= 0 && 
        exercisesCompleted >= 0 && 
        totalStretchTime >= 0
    }
    
    /// Returns validation errors if any
    var validationErrors: [String] {
        var errors: [String] = []
        
        if category == nil {
            errors.append("Session must belong to a category")
        }
        
        if currentExerciseIndex < 0 {
            errors.append("Current exercise index cannot be negative")
        }
        
        if exercisesCompleted < 0 {
            errors.append("Exercises completed cannot be negative")
        }
        
        if totalStretchTime < 0 {
            errors.append("Total stretch time cannot be negative")
        }
        
        return errors
    }
}
