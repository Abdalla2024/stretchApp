//
//  PaywallView.swift
//  stretchApp
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    // MARK: - Properties
    @EnvironmentObject var storeManager: StoreManager
    @Binding var isPresented: Bool
    @State private var currentTestimonial = 0
    @State private var selectedPlan: String = "template_weekly"
    @State private var testimonialTimer: Timer?
    
    // MARK: - Constants
    private struct Constants {
        static let appIconSize: CGFloat = 80
        static let cardHeight: CGFloat = 80
        static let testimonialHeight: CGFloat = 80
        static let animationDuration: Double = 0.5
        static let testimonialInterval: Double = 3.0
    }
    
    private let testimonials = [
        Testimonial(text: "This app has completely transformed my flexibility routine. I can feel the difference in just a week!", author: "Emma L."),
        Testimonial(text: "The guided stretches are perfect for my busy schedule. I love how I can target specific body parts.", author: "David M."),
        Testimonial(text: "Finally found an app that makes stretching enjoyable and effective. My back pain has significantly reduced.", author: "Sarah K.")
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    appIconSection
                    featuresSection
                    testimonialsSection
                    subscriptionPlansSection
                    purchaseButtonSection
                    bottomLinksSection
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundStyle(.blue)
                }
            }
            .onChange(of: storeManager.isSubscribed) { _, newValue in
                if newValue {
                    isPresented = false
                }
            }
            .onAppear {
                startTestimonialTimer()
            }
            .onDisappear {
                testimonialTimer?.invalidate()
            }
        }
    }
    
    // MARK: - View Components
    private var appIconSection: some View {
        Image(systemName: "figure.flexibility")
            .font(.system(size: Constants.appIconSize))
            .foregroundStyle(.blue)
            .padding(.top, 20)
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureRow(icon: "figure.flexibility", text: "All 25 Body Part Categories")
            FeatureRow(icon: "clock.fill", text: "125+ Guided Stretches")
            FeatureRow(icon: "sparkles", text: "Premium Stretch Access")
        }
        .padding(.horizontal, 24)
    }
    
    private var testimonialsSection: some View {
        VStack(spacing: 12) {
            starsView
            
            VStack(spacing: 8) {
                testimonialTabView
                pageIndicator
            }
        }
    }
    
    private var starsView: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.system(size: 16))
            }
        }
    }
    
    private var testimonialTabView: some View {
        TabView(selection: $currentTestimonial) {
            ForEach(Array(testimonials.enumerated()), id: \.offset) { index, testimonial in
                VStack(spacing: 8) {
                    Text(testimonial.text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                    
                    Text("- \(testimonial.author)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(height: Constants.testimonialHeight)
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: Constants.testimonialHeight)
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<testimonials.count, id: \.self) { index in
                Circle()
                    .fill(currentTestimonial == index ? .blue : .gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }
    
    private var subscriptionPlansSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Plan")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)
            
            VStack(spacing: 12) {
                ForEach(storeManager.products, id: \.id) { product in
                    SubscriptionPlanCard(
                        product: product,
                        isSelected: selectedPlan == product.id,
                        onTap: {
                            selectedPlan = product.id
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var purchaseButtonSection: some View {
        VStack(spacing: 16) {
            if let selectedProduct = storeManager.products.first(where: { $0.id == selectedPlan }) {
                Button(action: {
                    Task {
                        await storeManager.purchase(selectedProduct)
                    }
                }) {
                    HStack {
                        if storeManager.purchaseState == .purchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Start \(selectedProduct.displayName)")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.blue)
                    )
                }
                .disabled(storeManager.purchaseState == .purchasing)
                
                if case .failed(let error) = storeManager.purchaseState {
                    Text(error.localizedDescription)
                        .font(.system(size: 14))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var bottomLinksSection: some View {
        VStack(spacing: 16) {
            Button("Restore Purchases") {
                Task {
                    await storeManager.restorePurchases()
                }
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.blue)
            
            Text("Cancel anytime. Terms and Privacy Policy apply.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Helper Methods
    private func startTestimonialTimer() {
        testimonialTimer = Timer.scheduledTimer(withTimeInterval: Constants.testimonialInterval, repeats: true) { _ in
            withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                currentTestimonial = (currentTestimonial + 1) % testimonials.count
            }
        }
    }
}

// MARK: - Supporting Views
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
}

struct SubscriptionPlanCard: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    if product.type == .autoRenewable {
                        Text("\(product.displayPrice) per week")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(product.displayPrice)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? .blue : .gray)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .blue.opacity(0.1) : .gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? .blue : .gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct Testimonial {
    let text: String
    let author: String
}

// MARK: - Previews
#Preview {
    PaywallView(isPresented: .constant(true))
        .environmentObject(StoreManager())
}
