# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

stretchApp is a native iOS stretching exercise application built with SwiftUI and SwiftData (iOS 17+). It provides guided stretching sessions for 21 body parts with 105 exercises total.

## Development Commands

### Building and Running
```bash
# Open in Xcode (primary development environment)
open stretchApp.xcodeproj

# Build from command line
xcodebuild -project stretchApp.xcodeproj -scheme stretchApp build

# Run on simulator
xcodebuild -project stretchApp.xcodeproj -scheme stretchApp -destination 'platform=iOS Simulator,name=iPhone 15' run

# Run tests
xcodebuild test -project stretchApp.xcodeproj -scheme stretchApp -destination 'platform=iOS Simulator,name=iPhone 15'

# Clean build folder
xcodebuild -project stretchApp.xcodeproj -scheme stretchApp clean
```

### Testing Individual Components
```bash
# Run a specific test class
xcodebuild test -project stretchApp.xcodeproj -scheme stretchApp -only-testing:stretchAppTests/SpecificTestClass

# Run with verbose output for debugging
xcodebuild test -project stretchApp.xcodeproj -scheme stretchApp -verbose
```

## Architecture

### MVVM Pattern with SwiftData
The app follows MVVM architecture with SwiftData for persistence:

1. **Models** (`stretchApp/Models/`): SwiftData models that define the data schema
   - `StretchCategory`: 21 body part categories
   - `StretchExercise`: 105 exercises linked to categories  
   - `StretchSession`: User session tracking
   - `UserPreferences`: App settings and state

2. **ViewModels** (`stretchApp/ViewModels/`): Business logic and state management
   - `StretchCategoriesViewModel`: Manages category selection and navigation
   - `StretchSessionViewModel`: Controls exercise sessions, timers, and progression

3. **Views** (`stretchApp/Views/`): SwiftUI views organized by feature
   - Main flow: `BodyPartSelectionView` → `StretchSessionView`
   - Supporting: Onboarding, Settings, Paywall

### Data Flow
- **SwiftData Context**: Injected via `@Environment(\.modelContext)` through view hierarchy
- **State Management**: ViewModels use `@Published` properties for reactive UI updates
- **Session Flow**: Categories → Exercises → Timer → Progress tracking

### Key Technical Decisions

1. **SwiftData over Core Data**: Requires iOS 17+ but provides modern Swift-first persistence
2. **StoreKit Integration**: Premium subscriptions setup (currently disabled in code)
3. **Image Assets**: 105 numbered exercise images (1-1.png to 21-5.png format)
4. **JSON Data Loading**: Exercise data stored in `plan/stretches.json`

## Important Implementation Details

### Timer System
The timer in `StretchSessionViewModel` manages:
- 30-60 second exercise durations
- Automatic progression between exercises
- Pause/resume functionality
- Session completion tracking

Recent bug fixes addressed timer issues - be careful when modifying timer logic.

### Premium Features
StoreManager handles subscriptions but premium restrictions are currently commented out. When re-enabling:
1. Check `isPremium` computed property in StoreManager
2. Limit free users to first 2 exercises per category
3. Test StoreKit configuration in `plan/stretchApp.storekit`

### Data Initialization
Exercise data loads from `stretches.json` on first launch. The initialization happens in:
- `StretchCategoriesViewModel.loadExercises()`
- Data persists via SwiftData after initial load

## Common Development Tasks

### Adding New Exercises
1. Update `plan/stretches.json` with new exercise data
2. Add corresponding image to `images/` folder (format: `categoryIndex-exerciseIndex.png`)
3. Clear app data to reload from JSON on next launch

### Modifying Premium Logic
Premium restrictions are in `StretchCategoriesViewModel.exercises(for:)` - currently returns all exercises regardless of premium status.

### Working with SwiftData
- Models must be `@Model` decorated
- Use `@Query` for fetching data in views
- Access context via `@Environment(\.modelContext)`
- Remember to call `modelContext.save()` after changes

## Testing Considerations

Current test coverage is minimal. When adding tests:
- Use Swift Testing framework for new unit tests
- Mock SwiftData context for ViewModel tests
- Test timer logic thoroughly (previously buggy area)
- Verify premium/free user flows