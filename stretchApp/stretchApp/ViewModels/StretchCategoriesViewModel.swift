//
//  StretchCategoriesViewModel.swift
//  stretchApp
//
//  Created by Abdalla Abdelmagid on 8/9/25.
//

import Foundation
import SwiftData
import SwiftUI

/// ViewModel for managing stretch categories data and state
@MainActor
final class StretchCategoriesViewModel: ObservableObject {
    
    // MARK: - Properties
    
    /// Model context for SwiftData operations
    private let modelContext: ModelContext
    
    /// Published properties for UI updates
    @Published var categories: [StretchCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public Methods
    
    /// Load all stretch categories
    func loadCategories() async {
        print("🚀 Starting to load categories...")
        print("🔍 Current categories count: \(self.categories.count)")
        isLoading = true
        errorMessage = nil
        
        do {
            let descriptor = FetchDescriptor<StretchCategory>(
                sortBy: [SortDescriptor(\.name)]
            )
            
            let fetchedCategories = try modelContext.fetch(descriptor)
            print("📊 Found \(fetchedCategories.count) existing categories in database")
            
            // Always recreate from JSON to ensure data is up to date with the JSON file
            print("🔄 Clearing existing data and recreating from JSON...")
            await clearAndRecreateFromJSON()
            print("🔍 After recreation, categories count: \(self.categories.count)")
            
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
            print("❌ Error loading categories: \(error)")
        }
        
        isLoading = false
        print("🏁 Finished loading categories. Final count: \(self.categories.count)")
    }
    
    /// Refresh categories data
    func refresh() async {
        await loadCategories()
    }
    
    /// Force clear all data and recreate from JSON (for debugging)
    func forceClearAndRecreate() async {
        await clearAndRecreateFromJSON()
    }
    
    // MARK: - Private Methods
    
    /// Clear all existing data and recreate from JSON
    private func clearAndRecreateFromJSON() async {
        do {
            // First clear the published categories array on main thread
            await MainActor.run {
                self.categories = []
            }
            
            // Delete all existing categories and exercises with more aggressive approach
            let categoryDescriptor = FetchDescriptor<StretchCategory>()
            let existingCategories = try modelContext.fetch(categoryDescriptor)
            
            let exerciseDescriptor = FetchDescriptor<StretchExercise>()
            let existingExercises = try modelContext.fetch(exerciseDescriptor)
            
            // Also delete any sessions that might be referencing old data
            let sessionDescriptor = FetchDescriptor<StretchSession>()
            let existingSessions = try modelContext.fetch(sessionDescriptor)
            
            print("🗑️ Deleting \(existingCategories.count) categories, \(existingExercises.count) exercises, and \(existingSessions.count) sessions")
            
            // Delete in order: sessions first, then exercises, then categories
            for session in existingSessions {
                modelContext.delete(session)
            }
            for exercise in existingExercises {
                modelContext.delete(exercise)
            }
            for category in existingCategories {
                modelContext.delete(category)
            }
            
            // Force save and refresh context
            try modelContext.save()
            print("✅ Cleared existing data")
            
            // Add a small delay to ensure database operations complete
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            // Now recreate from JSON
            await createCategoriesFromJSON()
            
        } catch {
            errorMessage = "Failed to clear and recreate data: \(error.localizedDescription)"
            print("❌ Error clearing and recreating data: \(error)")
        }
    }
    
    /// Create categories from the stretches.json file
    private func createCategoriesFromJSON() async {
        print("🔍 Creating categories from stretches.json file...")
        
        // Load data from stretches.json file
        guard let url = Bundle.main.url(forResource: "stretches", withExtension: "json") else {
            errorMessage = "Failed to find stretches.json file in bundle"
            print("❌ Error: stretches.json file not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let stretchData = try JSONDecoder().decode([StretchData].self, from: data)
            print("📊 Loaded \(stretchData.count) stretches from JSON file")
            
            // Debug: Check Abdominals data specifically
            let abdominalsData = stretchData.filter { $0.bodyPart == "Abdominals" }
            print("🔍 Abdominals JSON data:")
            for stretch in abdominalsData {
                print("  \(stretch.stretchNumber): \(stretch.stretchName) - \(stretch.stretchTimeSec)s")
            }
            
            // Group stretches by body part
            let groupedStretches = Dictionary(grouping: stretchData) { $0.bodyPart }
            print("🏷️ Found \(groupedStretches.count) body part categories")
            
            // Icon mapping for each body part
            let iconMapping: [String: String] = [
                "Neck": "figure.flexibility",
                "Shoulders": "figure.strengthtraining.traditional",
                "Upper Back": "figure.core.training",
                "Lower Back": "figure.core.training",
                "Hips": "figure.flexibility",
                "Hamstrings": "figure.flexibility",
                "Quads": "figure.flexibility",
                "Calves": "figure.flexibility",
                "Ankles": "figure.flexibility",
                "Chest": "figure.flexibility",
                "Wrists": "figure.flexibility",
                "Lats & Side Body": "figure.flexibility",
                "Quadratus Lumborum (QL)": "figure.core.training",
                "Abdominals": "figure.core.training",
                "Glutes": "figure.flexibility",
                "Adductors (Inner Thigh)": "figure.flexibility",
                "Hip Rotators": "figure.flexibility",
                "TFL / Lateral Thigh": "figure.flexibility",
                "Forearms": "figure.flexibility",
                "Hands & Fingers": "figure.flexibility",
                "Feet & Toes": "figure.flexibility"
            ]
            
            // Create categories for each body part
            for (bodyPart, stretches) in groupedStretches {
                let iconName = iconMapping[bodyPart] ?? "figure.flexibility"
                
                // Sort stretches by stretch number
                let sortedStretches = stretches.sorted { $0.stretchNumber < $1.stretchNumber }
                
                // Use the 4th image for "Feet & Toes", first image for all others
                let categoryImage: String?
                if bodyPart == "Feet & Toes" && sortedStretches.count >= 4 {
                    categoryImage = sortedStretches[3].image // 4th image (index 3)
                } else {
                    categoryImage = sortedStretches.first?.image // 1st image
                }
                
                let category = StretchCategory(
                    name: bodyPart,
                    iconName: iconName,
                    imageName: categoryImage,
                    stretchCount: stretches.count,
                    isPremium: false
                )
                
                // Create exercises for this category
                for (index, stretchItem) in sortedStretches.enumerated() {
                    // First stretch is free, rest require premium
                    let isPremium = index > 0
                    
                    let exercise = StretchExercise(
                        exerciseNumber: stretchItem.stretchNumber,
                        name: stretchItem.stretchName,
                        instruction: stretchItem.instruction,
                        stretchTimeSec: stretchItem.stretchTimeSec,
                        imageName: stretchItem.image,
                        category: category,
                        isPremium: isPremium
                    )
                    
                    // Debug: Log Abdominals exercises as they're created
                    if bodyPart == "Abdominals" {
                        print("  Creating exercise: \(exercise.name) - \(exercise.stretchTimeSec)s")
                    }
                    
                    category.stretches.append(exercise)
                    modelContext.insert(exercise)
                }
                
                modelContext.insert(category)
            }
            
            // Save to database
            try modelContext.save()
            print("💾 Saved JSON-based categories to database")
            
            // Fetch the categories we just created to ensure fresh data
            let descriptor = FetchDescriptor<StretchCategory>(
                sortBy: [SortDescriptor(\.name)]
            )
            let freshCategories = try modelContext.fetch(descriptor)
            
            // Ensure UI update happens on main thread
            await MainActor.run {
                self.categories = freshCategories
            }
            print("🔄 Fetched \(self.categories.count) categories after creation")
            
            // Debug: Verify the fetched Abdominals data
            if let abdominalsCategory = freshCategories.first(where: { $0.name == "Abdominals" }) {
                print("🔍 Fetched Abdominals category verification:")
                for exercise in abdominalsCategory.stretches.sorted(by: { $0.exerciseNumber < $1.exerciseNumber }) {
                    print("  \(exercise.exerciseNumber): \(exercise.name) - \(exercise.stretchTimeSec)s")
                }
            }
            
        } catch {
            errorMessage = "Failed to load or parse stretches.json: \(error.localizedDescription)"
            print("❌ Error loading/parsing stretches.json: \(error)")
        }
    }
}

// MARK: - Stretch Data Structure

/// Data structure for decoding the stretches.json file
struct StretchData: Codable {
    let bodyPart: String
    let stretchNumber: Int
    let stretchName: String
    let instruction: String
    let stretchTimeSec: Int
    let image: String
}
