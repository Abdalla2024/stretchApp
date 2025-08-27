//
//  SettingsView.swift
//  stretchApp
//
//  Created by Claude on 8/9/25.
//

import SwiftUI
import SwiftData

/// Settings view for app configuration and subscription management
struct SettingsView: View {
    
    // MARK: - Properties
    
    let storeManager: StoreManager
    let modelContext: ModelContext
    let onDismiss: () -> Void
    
    @State private var userPreferences: UserPreferences?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Black background matching app theme
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Settings Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Subscription Status
                            subscriptionSection
                            
                            // App Info
                            appInfoSection
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 44)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .task {
            loadUserPreferences()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App Icon
            Image(systemName: "figure.flexibility")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 8) {
                Text("Stretch App")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Text("Settings")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 32)
    }
    
    // MARK: - Subscription Section
    
    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Subscription")
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // Subscription Status
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Status")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(subscriptionStatusText)
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(subscriptionStatusColor)
                    }
                    
                    Spacer()
                    
                    if hasPremiumAccess {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.84, blue: 0.0),
                                        Color(red: 1.0, green: 0.72, blue: 0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.055, green: 0.247, blue: 0.255))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                
                // Subscription Details
                if hasPremiumAccess, let preferences = userPreferences {
                    VStack(spacing: 8) {
                        if let subscriptionType = preferences.subscriptionType {
                            HStack {
                                Text("Plan")
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text(subscriptionType == UserPreferences.SubscriptionType.lifetime ? "Lifetime" : "Weekly")
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if let subscriptionDate = preferences.subscriptionDate {
                            HStack {
                                Text("Started")
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text(subscriptionDate.formatted(date: .abbreviated, time: .omitted))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if let expirationDate = preferences.subscriptionExpirationDate {
                            HStack {
                                Text("Expires")
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text(expirationDate.formatted(date: .abbreviated, time: .omitted))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .font(.system(size: 14))
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.039, green: 0.373, blue: 0.349))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    if !hasPremiumAccess {
                        Button("Upgrade to Pro") {
                            // This would typically show the paywall
                            // For now, just dismiss and let the main view handle it
                            onDismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue)
                        )
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Button("Restore Purchases") {
                        Task {
                            await storeManager.restorePurchases()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                }
            }
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("App Information")
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                InfoRow(title: "Version", value: "1.0.0")
                InfoRow(title: "Build", value: "1")
                InfoRow(title: "Developer", value: "Abdalla Abdelmagid")
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.055, green: 0.247, blue: 0.255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasPremiumAccess: Bool {
        storeManager.hasPremiumAccess || userPreferences?.isSubscriptionValid == true
    }
    
    private var subscriptionStatusText: String {
        if hasPremiumAccess {
            return "Premium Active"
        } else {
            return "Free Plan"
        }
    }
    
    private var subscriptionStatusColor: Color {
        if hasPremiumAccess {
            return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
        } else {
            return .white
        }
    }
    
    // MARK: - Actions
    
    private func loadUserPreferences() {
        userPreferences = UserPreferences.getCurrentPreferences(from: modelContext)
    }
}

// MARK: - Info Row Component

private struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .foregroundColor(.white)
        }
        .font(.system(size: 14))
    }
}

// MARK: - Previews

#Preview("Settings View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserPreferences.self, configurations: config)
    
    SettingsView(
        storeManager: StoreManager(),
        modelContext: container.mainContext,
        onDismiss: {}
    )
}
