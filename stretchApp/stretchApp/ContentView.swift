//
//  ContentView.swift
//  stretchApp
//
//  Created by Abdalla Abdelmagid on 8/9/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var userPreferences: UserPreferences?
    @State private var showingOnboarding = false
    
    var body: some View {
        Group {
            if showingOnboarding {
                OnboardingView {
                    completeOnboarding()
                }
            } else {
                BodyPartSelectionView(modelContext: modelContext)
            }
        }
        .task {
            loadUserPreferences()
        }
    }
    
    private func loadUserPreferences() {
        userPreferences = UserPreferences.getCurrentPreferences(from: modelContext)
        showingOnboarding = !(userPreferences?.hasSeenOnboarding ?? false)
    }
    
    private func completeOnboarding() {
        userPreferences?.completeOnboarding()
        showingOnboarding = false
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving onboarding completion: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [StretchCategory.self, StretchExercise.self, StretchSession.self, UserPreferences.self], inMemory: true)
}
