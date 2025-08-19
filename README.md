# Stretch App

A comprehensive stretching app built with SwiftUI and SwiftData, designed to help users improve flexibility and mobility through guided stretching exercises.

## Features

### 🏃‍♂️ **Body Part Categories**

- **20+ Body Parts**: Neck, shoulders, upper/lower back, hips, hamstrings, quads, calves, ankles, chest, wrists, and more
- **Organized by Muscle Groups**: Easy navigation through different body areas
- **Visual Icons**: SF Symbols for each body part category

### ⏱️ **Guided Stretching Sessions**

- **Timer-Based Exercises**: Each stretch has a specific duration (15-60 seconds)
- **Clear Instructions**: Step-by-step guidance for each exercise
- **Progress Tracking**: Visual progress bars and session completion tracking
- **Navigation Controls**: Previous/Next buttons with play/pause timer

### 💎 **Premium Features**

- **Free Tier**: First stretch of each body part available for free
- **Premium Access**: Unlock all stretches with subscription
- **Subscription Plans**: Weekly ($3.99/week) and Lifetime ($19.99) options
- **3-Day Free Trial**: Try weekly plan risk-free

### 🎯 **User Experience**

- **Onboarding Flow**: Welcome screen for first-time users
- **Settings Management**: Subscription status and app information
- **Dark Theme**: Beautiful black background with blue accents
- **Responsive Design**: Optimized for all iOS devices

## Technical Architecture

### **Models** (SwiftData)

- `StretchCategory`: Body part categories with premium status
- `StretchExercise`: Individual stretch exercises with timing
- `StretchSession`: User session tracking and progress
- `UserPreferences`: Onboarding and subscription state

### **ViewModels**

- `StretchCategoriesViewModel`: Manages category loading and JSON parsing
- `StretchSessionViewModel`: Handles exercise progression and session state

### **Views**

- `ContentView`: Main app coordinator with onboarding logic
- `BodyPartSelectionView`: Grid of body part categories
- `StretchSessionView`: Individual stretching session with timer
- `OnboardingView`: Welcome and feature introduction
- `PaywallView`: Subscription options and purchase flow
- `SettingsView`: App configuration and subscription status

### **Services**

- `StoreKitManager`: In-app purchase handling and subscription validation

## Data Structure

The app uses a `stretches.json` file containing:

```json
{
  "bodyPart": "Neck",
  "stretchNumber": 1,
  "stretchName": "Chin Tucks (Seated/Standing)",
  "instruction": "Sit or stand tall. Gently draw your chin straight back...",
  "stretchTimeSec": 30
}
```

## Setup Instructions

1. **Clone the repository**
2. **Open in Xcode**: Open `stretchApp.xcodeproj`
3. **Configure StoreKit**: Update `stretchApp.storekit` with your product IDs
4. **Build and Run**: Select your target device and run the app

## StoreKit Configuration

The app includes a StoreKit configuration file for testing:

- **Weekly Plan**: `weekly_399` - $3.99/week with 3-day free trial
- **Lifetime Plan**: `lifetimeplan` - $19.99 one-time purchase

## Premium Logic

- **Free Users**: Can access the first stretch of each body part
- **Premium Users**: Full access to all stretches across all categories
- **Subscription Validation**: Uses StoreKit for purchase verification with UserPreferences fallback

## Development Notes

- Built with **SwiftUI** and **SwiftData** for modern iOS development
- Uses **SF Symbols** for consistent iconography
- Implements **MVVM** architecture pattern
- Follows **Apple Human Interface Guidelines** for iOS design

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## License

This project is created for educational and personal use.

---

**Developer**: Abdalla Abdelmagid  
**Created**: August 2025
