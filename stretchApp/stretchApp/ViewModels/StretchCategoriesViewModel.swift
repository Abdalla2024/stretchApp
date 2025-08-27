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
            
            // If no categories exist, create them from the JSON data
            if fetchedCategories.isEmpty {
                print("🆕 No categories found, creating from JSON...")
                await createCategoriesFromJSON()
                print("🔍 After creation, categories count: \(self.categories.count)")
            } else {
                print("✅ Using existing categories")
                self.categories = fetchedCategories
                print("🔍 After assignment, categories count: \(self.categories.count)")
            }
            
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
    
    // MARK: - Private Methods
    
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
                
                let category = StretchCategory(
                    name: bodyPart,
                    iconName: iconName,
                    stretchCount: stretches.count,
                    isPremium: false
                )
                
                // Sort stretches by stretch number
                let sortedStretches = stretches.sorted { $0.stretchNumber < $1.stretchNumber }
                
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
                    
                    category.stretches.append(exercise)
                    modelContext.insert(exercise)
                }
                
                modelContext.insert(category)
            }
            
            // Save to database
            try modelContext.save()
            print("💾 Saved JSON-based categories to database")
            
            // Fetch the categories we just created
            let descriptor = FetchDescriptor<StretchCategory>(
                sortBy: [SortDescriptor(\.name)]
            )
            self.categories = try modelContext.fetch(descriptor)
            print("🔄 Fetched \(self.categories.count) categories after creation")
            
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
