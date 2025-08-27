//
//  StretchSessionView.swift
//  stretchApp
//
//  Created by Claude on 8/9/25.
//

import SwiftUI
import SwiftData

/// Main stretch session view with timer and exercise progression
struct StretchSessionView: View {
    
    // MARK: - Properties
    
    let category: StretchCategory
    let modelContext: ModelContext
    let storeManager: StoreManager
    
    @StateObject private var stretchSessionVM: StretchSessionViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Timer state
    @State private var timeRemaining: Int = 0
    @State private var isTimerRunning = false
    @State private var timer: Timer?
    
    // Paywall state
    @State private var showingPaywall = false
    
    // MARK: - Initialization
    
    init(category: StretchCategory, modelContext: ModelContext, storeManager: StoreManager) {
        self.category = category
        self.modelContext = modelContext
        self.storeManager = storeManager
        self._stretchSessionVM = StateObject(wrappedValue: StretchSessionViewModel(modelContext: modelContext, storeManager: storeManager))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Exercise Content
                if stretchSessionVM.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(
                                    tint: .white
                                )
                            )
                            .scaleEffect(1.5)
                        
                        Text("Loading Exercise...")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.8))
                    }
                } else if let errorMessage = stretchSessionVM.errorMessage {
                    ErrorView(message: errorMessage) {
                        Task { await initializeSession() }
                    }
                } else {
                    exerciseView
                }
                
                Spacer()
                
                // Control buttons
                controlButtons
                    .padding(.bottom, 44)
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    stopTimer()
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                        Text("Back")
                            .font(.system(size: 17, weight: .regular))
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .task {
            await initializeSession()
        }
        .onDisappear {
            stopTimer()
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(isPresented: $showingPaywall)
                .environmentObject(storeManager)
        }
    }
    
    // MARK: - Exercise View
    
    private var exerciseView: some View {
        VStack(spacing: 30) {
            // Exercise Header
            VStack(spacing: 16) {
                // Exercise Name
                Text(stretchSessionVM.currentExercise?.name ?? "")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .onAppear {
                        if let exercise = stretchSessionVM.currentExercise {
                            print("🖥️ UI displaying exercise: \(exercise.name) - \(exercise.stretchTimeSec)s")
                        }
                    }
                    .onChange(of: stretchSessionVM.currentExercise) { _, newExercise in
                        if let exercise = newExercise {
                            print("🖥️ UI exercise changed to: \(exercise.name) - \(exercise.stretchTimeSec)s")
                            // Restart timer whenever exercise changes
                            startTimer()
                        }
                    }
                
                // Exercise Image
                if let imageName = stretchSessionVM.currentExercise?.imageName {
                    // Try to load the image
                    if let uiImage = UIImage(named: imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 280, maxHeight: 200)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    } else {
                        // Debug: Show that image was not found
                        VStack {
                            Image(systemName: "photo.badge.exclamationmark")
                                .font(.system(size: 40))
                                .foregroundColor(.red)
                            Text("Image not found: \(imageName)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    // Fallback to body part icon if no image name
                    VStack {
                        Image(systemName: category.iconName)
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        Text("No image name")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Timer Display
            VStack(spacing: 20) {
                Text("Hold this stretch for")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.8))
                
                Text(timeString(from: timeRemaining))
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .monospacedDigit()
                    .onAppear {
                        print("🖥️ UI displaying timeRemaining: \(timeRemaining)")
                    }
                    .onChange(of: timeRemaining) { _, newValue in
                        print("🖥️ UI timeRemaining changed to: \(newValue)")
                    }
                
                // Progress Bar
                ProgressView(value: progressValue)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            // Instructions
            ScrollView {
                Text(stretchSessionVM.currentExercise?.instruction ?? "")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
            }
            .frame(maxHeight: 120)
        }
    }
    
    // MARK: - Control Buttons
    
    private var controlButtons: some View {
        HStack(spacing: 22) {
            // Previous
            Button(action: { 
                stopTimer()
                Task { await stretchSessionVM.previousExercise() }
                startTimer()
            }) {
                VStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(stretchSessionVM.canGoPrevious ? Color.white : Color.white.opacity(0.5))
                    Text("Previous")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(stretchSessionVM.canGoPrevious ? Color.white : Color.white.opacity(0.5))
                }
                .frame(width: 84, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(red: 0.10, green: 0.12, blue: 0.13))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(stretchSessionVM.canGoPrevious ? Color(red: 0.16, green: 0.18, blue: 0.20) : Color(red: 0.12, green: 0.13, blue: 0.15), lineWidth: 1)
                        )
                )
                .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 8)
            }
            .disabled(!stretchSessionVM.canGoPrevious)

            // Play/Pause
            Button(action: toggleTimer) {
                VStack(spacing: 6) {
                    Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.blue)
                    Text(isTimerRunning ? "Pause" : "Start")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.blue)
                }
                .frame(width: 96, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(red: 0.10, green: 0.12, blue: 0.13))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(.blue.opacity(0.35), lineWidth: 1)
                        )
                )
                .shadow(color: .blue.opacity(0.25), radius: 16, x: 0, y: 10)
                .shadow(color: .black.opacity(0.45), radius: 14, x: 0, y: 10)
            }

            // Next
            if stretchSessionVM.canGoNext {
                Button(action: { 
                    stopTimer()
                    
                    // Check if next exercise requires premium access
                    if stretchSessionVM.checkNextExercisePremiumAccess() {
                        showingPaywall = true
                    } else {
                        Task { await stretchSessionVM.nextExercise() }
                        startTimer()
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.white)
                        Text("Next")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.white)
                    }
                    .frame(width: 84, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(red: 0.10, green: 0.12, blue: 0.13))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(red: 0.16, green: 0.18, blue: 0.20), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 8)
                }
            }
        }
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        guard let exercise = stretchSessionVM.currentExercise else { return }
        
        // Always stop any existing timer first
        stopTimer()
        
        // Debug: Log what exercise and timing we're using
        print("🕐 Starting timer for: \(exercise.name) - \(exercise.stretchTimeSec)s")
        
        // Force update the timeRemaining 
        timeRemaining = exercise.stretchTimeSec
        isTimerRunning = true
        print("🕐 Timer set timeRemaining to: \(timeRemaining)")
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                // Use Task to handle async call
                Task { @MainActor in
                    stretchSessionVM.addStretchTime(1)
                }
            } else {
                stopTimer()
                // Auto-advance to next exercise
                Task { @MainActor in
                    // Check if next exercise requires premium access
                    if stretchSessionVM.checkNextExercisePremiumAccess() {
                        showingPaywall = true
                    } else {
                        await stretchSessionVM.nextExercise()
                        startTimer()
                    }
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
    
    private func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    // MARK: - Computed Properties
    
    private var progressValue: Double {
        guard let exercise = stretchSessionVM.currentExercise else { return 0.0 }
        let totalTime = Double(exercise.stretchTimeSec)
        let remaining = Double(timeRemaining)
        let progress = (totalTime - remaining) / totalTime
        return max(0.0, min(1.0, progress)) // Ensure value is between 0 and 1
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        } else {
            return "\(remainingSeconds)"
        }
    }
    
    // MARK: - Initialization
    
    @MainActor
    private func initializeSession() async {
        // Get fresh category data from database to ensure we have the latest exercises
        do {
            let descriptor = FetchDescriptor<StretchCategory>(
                sortBy: [SortDescriptor(\.name)]
            )
            let allCategories = try modelContext.fetch(descriptor)
            
            if let freshCategory = allCategories.first(where: { $0.id == category.id }) {
                print("🔄 Using fresh category data for: \(freshCategory.name)")
                await stretchSessionVM.startNewSession(for: freshCategory)
            } else {
                print("⚠️ Could not find fresh category, using original")
                await stretchSessionVM.startNewSession(for: category)
            }
        } catch {
            print("❌ Error fetching fresh category: \(error)")
            await stretchSessionVM.startNewSession(for: category)
        }
        
        startTimer()
    }
}

// MARK: - Supporting Views

private struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56, weight: .medium))
                .foregroundColor(Color(red: 1.0, green: 0.58, blue: 0.0))
            
            Text("Oops!")
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(.white)
            
            Text(message)
                .font(.system(size: 16, weight: .medium, design: .default))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.8))
                .lineSpacing(2)
            
            Button(action: onRetry) {
                Text("Try Again")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.13, green: 0.13, blue: 0.15))
                            .stroke(Color(red: 0.19, green: 0.19, blue: 0.22), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
        }
        .padding(32)
    }
}

// MARK: - Previews

#Preview("Stretch Session") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StretchCategory.self, StretchExercise.self, StretchSession.self, configurations: config)
    
    let sampleCategory = StretchCategory(
        name: "Neck",
        iconName: "figure.flexibility",
        stretchCount: 5
    )
    
    StretchSessionView(category: sampleCategory, modelContext: container.mainContext, storeManager: StoreManager())
}
