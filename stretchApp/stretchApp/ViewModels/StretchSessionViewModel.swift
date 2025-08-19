//
//  StretchSessionViewModel.swift
//  stretchApp
//
//  Created by Claude on 8/9/25.
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
    
    /// Loading state
    @Published var isLoading = false
    
    /// Error message
    @Published var errorMessage: String?
    
    /// Whether the session is completed
    @Published var isSessionCompleted = false
    
    /// Whether user has premium access
    var hasPremiumAccess: Bool
    
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
    
    init(modelContext: ModelContext, hasPremiumAccess: Bool = false) {
        self.modelContext = modelContext
        self.hasPremiumAccess = hasPremiumAccess
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
            self.isSessionCompleted = false
            
            // Save session
            try modelContext.save()
            
        } catch {
            errorMessage = "Failed to start session: \(error.localizedDescription)"
            print("Error starting session: \(error)")
        }
        
        isLoading = false
    }
    
    /// Move to the next exercise
    func nextExercise() async {
        guard canGoNext else {
            await completeSession()
            return
        }
        
        let nextIndex = currentExerciseIndex + 1
        let nextExercise = allExercises[nextIndex]
        
        // Check if next exercise requires premium
        if nextExercise.isPremium && !hasPremiumAccess {
            // Show paywall for premium exercise
            // For now, just skip to the next free exercise
            await skipToNextFreeExercise()
            return
        }
        
        currentExercise = nextExercise
        
        // Update session
        currentSession?.nextExercise()
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving session: \(error)")
        }
    }
    
    /// Skip to the next free exercise
    private func skipToNextFreeExercise() async {
        let nextFreeIndex = allExercises.dropFirst(currentExerciseIndex + 1).firstIndex { !$0.isPremium }
        
        if let freeIndex = nextFreeIndex {
            currentExercise = allExercises[freeIndex]
            currentSession?.nextExercise()
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving session: \(error)")
            }
        } else {
            // No more free exercises, complete session
            await completeSession()
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
    
    /// Complete the current session
    func completeSession() async {
        currentSession?.completeSession()
        isSessionCompleted = true
        
        do {
            try modelContext.save()
        } catch {
            print("Error completing session: \(error)")
        }
    }
    
    /// Add stretch time to the session
    func addStretchTime(_ seconds: Int) {
        currentSession?.addStretchTime(seconds)
    }
}
