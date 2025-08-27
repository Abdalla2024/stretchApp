//
//  OnboardingView.swift
//  stretchApp
//
//  Created by Abdalla Abdelmagid on 8/9/25.
//

import SwiftUI

/// Onboarding view showcasing app features and benefits
struct OnboardingView: View {
    
    // MARK: - Properties
    
    let onContinue: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Black background matching app theme
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // App Icon and Welcome
                VStack(spacing: 24) {
                    // App Icon
                    Image(systemName: "figure.flexibility")
                        .font(.system(size: 120))
                        .foregroundColor(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    // Welcome Title
                    VStack(spacing: 8) {
                        Text("Welcome to")
                            .font(.system(size: 24, weight: .medium, design: .default))
                            .foregroundColor(Color.white.opacity(0.8))
                        
                        Text("Stretch App")
                            .font(.system(size: 36, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Features List
                VStack(spacing: 32) {
                    OnboardingFeatureRow(
                        icon: "figure.flexibility",
                        title: "20+ Body Parts",
                        description: "Neck, shoulders, back, hips, and more!"
                    )
                    
                    OnboardingFeatureRow(
                        icon: "timer",
                        title: "Guided Timers",
                        description: "Perfect timing for each stretch exercise"
                    )
                    
                    OnboardingFeatureRow(
                        icon: "arrow.right.circle.fill",
                        title: "Easy Navigation",
                        description: "Simple progression through your routine"
                    )
                    
                    OnboardingFeatureRow(
                        icon: "heart.fill",
                        title: "Better Flexibility",
                        description: "Improve mobility and reduce stiffness"
                    )
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Continue Button
                Button(action: onContinue) {
                    HStack(spacing: 12) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue,
                                        Color.blue.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: .blue.opacity(0.4), radius: 20, x: 0, y: 8)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 44)
            }
        }
    }
}

// MARK: - Feature Row Component

private struct OnboardingFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 20) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(Color.white.opacity(0.7))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("Onboarding View") {
    OnboardingView {
        print("Continue tapped")
    }
}
