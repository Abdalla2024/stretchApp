//
//  StretchSessionViewModel.swift
//  stretchApp
//
//  Created by Abdalla Abdelmagid on 8/9/25.
//

import Foundation
import SwiftData
import SwiftUI

/// ViewModel for managing stretch session state and navigation
@MainActor
final class StretchSessionViewModel: ObservableObject {
    
    // MARK: - Properties
    
    /// Model context for SwiftData operations
    private let modelContext: ModelContext
    
    /// Current stretch session
    @Published var currentSession: StretchSession?
    
    /// Current category being stretched
    @Published var currentCategory: StretchCategory?
    
    /// Current exercise being displayed
    @Published var currentExercise: StretchExercise?
    
    /// All exercises in the current category
    @Published var allExercises: [StretchExercise] = []
    
    /// Whether the session is currently loading
    @Published var isLoading = false
    
    /// Error message if something goes wrong
    @Published var errorMessage: String?
    
    /// Store manager for premium access
    @ObservedObject var storeManager: StoreManager
    
    // MARK: - Computed Properties
    
    /// Current exercise index
    var currentExerciseIndex: Int {
        guard let currentExercise = currentExercise,
              let index = allExercises.firstIndex(where: { $0.id == currentExercise.id }) else {
            return 0
        }
        return index
    }
    
    /// Whether we can go to the previous exercise
    var canGoPrevious: Bool {
        currentExerciseIndex > 0
    }
    
    /// Whether we can go to the next exercise
    var canGoNext: Bool {
        currentExerciseIndex < allExercises.count - 1
    }
    
    /// Progress through the session (0.0 to 1.0)
    var sessionProgress: Double {
        guard !allExercises.isEmpty else { return 0.0 }
        return Double(currentExerciseIndex + 1) / Double(allExercises.count)
    }
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext, storeManager: StoreManager) {
        self.modelContext = modelContext
        self.storeManager = storeManager
    }
    
    // MARK: - Public Methods
    
    /// Start a new stretch session for a category
    func startNewSession(for category: StretchCategory) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create new session
            let session = StretchSession(category: category)
            modelContext.insert(session)
            
            // Get all exercises for this category
            let descriptor = FetchDescriptor<StretchExercise>(
                sortBy: [SortDescriptor(\.exerciseNumber)]
            )
            
            let allExercises = try modelContext.fetch(descriptor)
            
            // Filter exercises for this category
            let exercises = allExercises.filter { $0.category?.id == category.id }
            
            // Update state
            self.currentSession = session
            self.currentCategory = category
            self.allExercises = exercises
            self.currentExercise = exercises.first
            
            // Save session
            try modelContext.save()
            
        } catch {
            errorMessage = "Failed to start session: \(error.localizedDescription)"
            print("Error starting session: \(error)")
        }
        
        isLoading = false
    }
    
    /// Check if next exercise requires premium access
    func checkNextExercisePremiumAccess() -> Bool {
        guard canGoNext else { return false }
        
        let nextIndex = currentExerciseIndex + 1
        let nextExercise = allExercises[nextIndex]
        
        return nextExercise.isPremium && !storeManager.isSubscribed
    }
    
    /// Move to the next exercise
    func nextExercise() async {
        guard canGoNext else {
            // Don't complete session automatically - just stay on the last exercise
            // User can still navigate back to previous exercises
            return
        }
        
        let nextIndex = currentExerciseIndex + 1
        let nextExercise = allExercises[nextIndex]
        
        // Temporarily remove premium restrictions - allow access to all exercises
        // TODO: Re-implement premium logic later
        currentExercise = nextExercise
        
        // Update session
        currentSession?.nextExercise()
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving session: \(error)")
        }
    }
    
    /// Move to the previous exercise
    func previousExercise() async {
        guard canGoPrevious else { return }
        
        let previousIndex = currentExerciseIndex - 1
        currentExercise = allExercises[previousIndex]
        
        // Update session
        currentSession?.previousExercise()
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving session: \(error)")
        }
    }
    
    /// Shuffle exercises
    func shuffleExercises() async {
        allExercises.shuffle()
        
        // Reset to first exercise
        currentExercise = allExercises.first
        currentSession?.resetSession()
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving shuffled session: \(error)")
        }
    }
    
    /// Restart the session
    func restartSession() async {
        guard let category = currentCategory else { return }
        await startNewSession(for: category)
    }
    
    /// Add stretch time to the session
    func addStretchTime(_ seconds: Int) {
        currentSession?.addStretchTime(seconds)
    }
}
