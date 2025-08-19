//
//  BodyPartSelectionView.swift
//  stretchApp
//
//  Created by Claude on 8/9/25.
//

import SwiftUI
import SwiftData

/// Main view for selecting body parts to stretch
/// Displays a grid of available body part categories with search functionality
struct BodyPartSelectionView: View {
    
    // MARK: - Properties
    
    /// Model context for SwiftData operations
    let modelContext: ModelContext
    
    /// ViewModel for managing category data and state
    @StateObject private var categoriesViewModel: StretchCategoriesViewModel
    
    /// StoreKit manager for premium purchases
    @State private var storeKitManager = StoreKitManager()
    
    /// User preferences for premium status
    @State private var userPreferences: UserPreferences?
    

    
    /// Settings presentation state
    @State private var showingSettings = false
    

    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self._categoriesViewModel = StateObject(wrappedValue: StretchCategoriesViewModel(modelContext: modelContext))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Stretch App")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(Color(red: 1, green: 1, blue: 1))
                        }
                    }
                }
                .task {
                    await loadInitialData()
                    loadUserPreferences()
                }
                .refreshable {
                    await refreshData()
                }

                .sheet(isPresented: $showingSettings) {
                    SettingsView(
                        storeKitManager: storeKitManager,
                        modelContext: modelContext,
                        onDismiss: {
                            showingSettings = false
                        }
                    )
                }
        }
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private var contentView: some View {
        if categoriesViewModel.isLoading {
            loadingView
        } else if let errorMessage = categoriesViewModel.errorMessage {
            errorView(message: errorMessage)
        } else if filteredCategories.isEmpty {
            emptyStateView
        } else {
            categoryGrid
        }
    }
    
    // MARK: - Category Grid
    
    private var categoryGrid: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 20) {
                ForEach(filteredCategories) { category in
                    // All categories are free - navigate to stretch session
                    NavigationLink(destination: StretchSessionView(category: category, modelContext: modelContext)) {
                        CategoryCardView(
                            category: category,
                            badgeType: .none,
                            onTap: { }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Grid Configuration
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 160), spacing: 20)
        ]
    }
    
    // MARK: - Sorted Categories
    
    private var filteredCategories: [StretchCategory] {
        print("🔍 filteredCategories called. ViewModel categories count: \(categoriesViewModel.categories.count)")
        // Sort categories: free categories first, then premium categories
        // Within each group, sort alphabetically by name
        let sorted = categoriesViewModel.categories.sorted { category1, category2 in
            if category1.isPremium == category2.isPremium {
                // Both have same premium status, sort alphabetically
                return category1.name.localizedCaseInsensitiveCompare(category2.name) == .orderedAscending
            } else {
                // Different premium status, free categories (isPremium = false) come first
                return !category1.isPremium && category2.isPremium
            }
        }
        print("🔍 filteredCategories returning \(sorted.count) categories")
        return sorted
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading Stretches...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                Task {
                    await refreshData()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.flexibility")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Categories Found")
                .font(.headline)
            
            Text("No stretch categories available")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var hasPremiumAccess: Bool {
        // Primary: Use StoreKitManager as the authoritative source of truth
        if storeKitManager.hasPremiumAccess {
            return true
        }
        
        // Only use UserPreferences as fallback if StoreKitManager failed to load products
        // This ensures we have offline functionality while maintaining StoreKit as source of truth
        if !storeKitManager.products.isEmpty {
            // StoreKitManager loaded successfully, trust its result (false)
            return false
        } else {
            // StoreKitManager failed to load, use cached UserPreferences as fallback
            return userPreferences?.isSubscriptionValid ?? false
        }
    }
    
    // MARK: - Actions
    
    private func loadInitialData() async {
        print("📱 BodyPartSelectionView: Starting to load initial data...")
        await categoriesViewModel.loadCategories()
        print("📱 BodyPartSelectionView: Finished loading initial data. Categories count: \(categoriesViewModel.categories.count)")
    }
    
    private func refreshData() async {
        await categoriesViewModel.refresh()
    }
    
    private func loadUserPreferences() {
        userPreferences = UserPreferences.getCurrentPreferences(from: modelContext)
    }
    

}

// MARK: - Category Badge Type

enum CategoryBadgeType {
    case crown    // Premium
    case none     // Free/unlocked
}

// MARK: - Category Card View

struct CategoryCardView: View {
    let category: StretchCategory
    let badgeType: CategoryBadgeType
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                // Category Icon
                Image(systemName: category.iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                VStack(spacing: 4) {
                    // Category Name
                    Text(category.name)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    // Stretch Count
                    Text("\(category.stretches.count) stretches")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.separator), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Badge (Crown for premium)
            if badgeType != .none {
                VStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.84, blue: 0.0),  // Gold
                                            Color(red: 1.0, green: 0.72, blue: 0.0)   // Darker gold
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.4), radius: 4, x: 0, y: 2)
                        .offset(x: -4, y: 4)
                    }
                    Spacer()
                }
            }
        }
        .accessibilityLabel(category.name)
        .accessibilityValue("\(category.stretches.count) stretches available")
        .accessibilityHint(accessibilityHintText)
        .accessibilityAddTraits(.isButton)
    }
    
    private var accessibilityHintText: String {
        switch badgeType {
        case .crown:
            return "Premium content - Double tap to upgrade"
        case .none:
            return "Double tap to start stretching"
        }
    }
}

// MARK: - Previews

#Preview("Main View") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: StretchCategory.self, StretchExercise.self, StretchSession.self, configurations: config)
    
    BodyPartSelectionView(modelContext: container.mainContext)
}

#Preview("Category Card") {
    let sampleCategory = StretchCategory(
        name: "Neck",
        iconName: "figure.flexibility",
        stretchCount: 5
    )
    
    CategoryCardView(
        category: sampleCategory,
        badgeType: .crown,
        onTap: {}
    )
    .frame(width: 160, height: 200)
    .padding()
}
