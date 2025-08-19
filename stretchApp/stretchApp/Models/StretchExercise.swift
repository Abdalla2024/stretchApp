//
//  StretchExercise.swift
//  stretchApp
//
//  Created by Claude on 8/9/25.
//

import Foundation
import SwiftData

@Model
final class StretchExercise {
    /// Unique identifier for the exercise
    @Attribute(.unique) var id: UUID
    
    /// Exercise number within the category
    var exerciseNumber: Int
    
    /// The name of the stretch exercise
    var name: String
    
    /// The instruction text for this stretch
    var instruction: String
    
    /// Duration in seconds for this stretch
    var stretchTimeSec: Int
    
    /// Whether this exercise has been completed/shown in current session
    var isCompleted: Bool
    
    /// Number of times this exercise has been used across all sessions
    var usageCount: Int
    
    /// Creation date for sorting purposes
    var createdAt: Date
    
    /// Last time this exercise was used
    var lastUsedAt: Date?
    
    /// Whether this exercise is marked as favorite by user
    var isFavorite: Bool
    
    /// Difficulty level (1-5) - can be used for filtering
    var difficultyLevel: Int
    
    /// Whether this exercise requires premium subscription
    var isPremium: Bool
    
    /// Relationship to category
    var category: StretchCategory?
    
    init(exerciseNumber: Int, name: String, instruction: String, stretchTimeSec: Int, category: StretchCategory? = nil, difficultyLevel: Int = 1, isPremium: Bool = false) {
        self.id = UUID()
        self.exerciseNumber = exerciseNumber
        self.name = name
        self.instruction = instruction
        self.stretchTimeSec = stretchTimeSec
        self.isCompleted = false
        self.usageCount = 0
        self.createdAt = Date()
        self.isFavorite = false
        self.difficultyLevel = max(1, min(5, difficultyLevel)) // Ensure 1-5 range
        self.isPremium = isPremium
        self.category = category
    }
    
    /// Mark exercise as used/completed
    func markAsUsed() {
        isCompleted = true
        usageCount += 1
        lastUsedAt = Date()
    }
    
    /// Reset exercise completion status (for new sessions)
    func resetCompletion() {
        isCompleted = false
    }
    
    /// Toggle favorite status
    func toggleFavorite() {
        isFavorite.toggle()
    }
    
    /// Computed property for display purposes
    var displayTitle: String {
        "Exercise \(exerciseNumber)"
    }
    
    /// Computed property to get category name safely
    var categoryName: String {
        category?.name ?? "Unknown"
    }
    
    /// Check if exercise is recently used (within last 24 hours)
    var isRecentlyUsed: Bool {
        guard let lastUsed = lastUsedAt else { return false }
        return Date().timeIntervalSince(lastUsed) < 24 * 60 * 60 // 24 hours
    }
    
    /// Format time for display
    var formattedTime: String {
        let minutes = stretchTimeSec / 60
        let seconds = stretchTimeSec % 60
        
        if minutes > 0 {
            return "\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - Validation Extensions
extension StretchExercise {
    /// Validates exercise data integrity
    var isValid: Bool {
        exerciseNumber > 0 && 
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        stretchTimeSec > 0 && 
        difficultyLevel >= 1 && 
        difficultyLevel <= 5
    }
    
    /// Returns validation errors if any
    var validationErrors: [String] {
        var errors: [String] = []
        
        if exerciseNumber <= 0 {
            errors.append("Exercise number must be greater than 0")
        }
        
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Exercise name cannot be empty")
        }
        
        if instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Exercise instruction cannot be empty")
        }
        
        if stretchTimeSec <= 0 {
            errors.append("Stretch time must be greater than 0")
        }
        
        if difficultyLevel < 1 || difficultyLevel > 5 {
            errors.append("Difficulty level must be between 1 and 5")
        }
        
        if category == nil {
            errors.append("Exercise must belong to a category")
        }
        
        return errors
    }
}

// MARK: - Comparable Conformance
extension StretchExercise: Comparable {
    static func < (lhs: StretchExercise, rhs: StretchExercise) -> Bool {
        if lhs.categoryName != rhs.categoryName {
            return lhs.categoryName < rhs.categoryName
        }
        return lhs.exerciseNumber < rhs.exerciseNumber
    }
    
    static func == (lhs: StretchExercise, rhs: StretchExercise) -> Bool {
        lhs.id == rhs.id
    }
}
