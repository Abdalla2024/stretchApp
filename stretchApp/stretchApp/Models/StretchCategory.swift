//
//  StretchCategory.swift
//  stretchApp
//
//  Created by Claude on 8/9/25.
//

import Foundation
import SwiftData

@Model
final class StretchCategory {
    /// Unique identifier for the category
    @Attribute(.unique) var id: UUID
    
    /// Display name of the body part (e.g., "Neck", "Shoulders", "Lower Back")
    var name: String
    
    /// Icon name for UI display
    var iconName: String
    
    /// Total number of stretches in this category
    var stretchCount: Int
    
    /// Creation date for sorting purposes
    var createdAt: Date
    
    /// Whether this category is currently active/available
    var isActive: Bool
    
    /// Whether this category requires premium subscription
    var isPremium: Bool
    
    /// Relationship to stretch exercises
    @Relationship(deleteRule: .cascade, inverse: \StretchExercise.category)
    var stretches: [StretchExercise] = []
    
    /// Relationship to stretch sessions
    @Relationship(deleteRule: .cascade, inverse: \StretchSession.category)
    var sessions: [StretchSession] = []
    
    init(name: String, iconName: String, stretchCount: Int = 0, isPremium: Bool = false) {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.stretchCount = stretchCount
        self.createdAt = Date()
        self.isActive = true
        self.isPremium = isPremium
    }
    
    /// Computed property to get actual stretch count from relationship
    var actualStretchCount: Int {
        stretches.count
    }
    
    /// Computed property to get active sessions count
    var activeSessionsCount: Int {
        sessions.filter { $0.isActive }.count
    }
    
    /// Get the icon name based on category name if not explicitly set
    static func defaultIconName(for categoryName: String) -> String {
        switch categoryName.lowercased() {
        case "neck":
            return "figure.flexibility"
        case "shoulders":
            return "figure.strengthtraining.traditional"
        case "upper back":
            return "figure.core.training"
        case "lower back":
            return "figure.core.training"
        case "hips":
            return "figure.flexibility"
        case "hamstrings":
            return "figure.flexibility"
        case "quads":
            return "figure.strengthtraining.traditional"
        case "calves":
            return "figure.flexibility"
        case "ankles":
            return "figure.flexibility"
        case "chest":
            return "figure.core.training"
        case "wrists":
            return "figure.flexibility"
        case "lats & side body":
            return "figure.core.training"
        case "quadratus lumborum (ql)":
            return "figure.core.training"
        case "abdominals":
            return "figure.core.training"
        case "glutes":
            return "figure.flexibility"
        case "adductors (inner thigh)":
            return "figure.flexibility"
        case "hip rotators":
            return "figure.flexibility"
        case "tfl / lateral thigh":
            return "figure.flexibility"
        case "forearms":
            return "figure.flexibility"
        case "hands & fingers":
            return "figure.flexibility"
        case "feet & toes":
            return "figure.flexibility"
        default:
            return "figure.flexibility"
        }
    }
}

// MARK: - Validation Extensions
extension StretchCategory {
    /// Validates category data integrity
    var isValid: Bool {
        !name.isEmpty && !iconName.isEmpty && stretchCount >= 0
    }
    
    /// Returns validation errors if any
    var validationErrors: [String] {
        var errors: [String] = []
        
        if name.isEmpty {
            errors.append("Category name cannot be empty")
        }
        
        if iconName.isEmpty {
            errors.append("Icon name cannot be empty")
        }
        
        if stretchCount < 0 {
            errors.append("Stretch count cannot be negative")
        }
        
        if stretchCount != actualStretchCount {
            errors.append("Stretch count mismatch: expected \(stretchCount), actual \(actualStretchCount)")
        }
        
        return errors
    }
}

// MARK: - Premium Category Configuration
extension StretchCategory {
    /// All categories are free by default - premium is controlled at the exercise level
    /// The first stretch of each body part is free, additional stretches require premium
    
    /// Check if a category name should be premium (currently all are free)
    static func shouldBePremium(_ categoryName: String) -> Bool {
        return false // All categories are free, premium is at exercise level
    }
    
    /// Update premium status based on category name
    func updatePremiumStatus() {
        self.isPremium = StretchCategory.shouldBePremium(self.name)
    }
}
