# Adding Missing Files to Xcode Project

The following files need to be added to the Xcode project to resolve compilation errors:

## Files to Add

### 1. AppRouter.swift
**Location:** `Utilities/AppRouter.swift`
**Target:** LagAuditApp
**Group:** Utilities

### 2. AuditViewModel.swift  
**Location:** `ViewModels/AuditViewModel.swift`
**Target:** LagAuditApp
**Group:** ViewModels

## How to Add Files in Xcode

1. **Open the Xcode project**
2. **Right-click on the appropriate group** (Utilities or ViewModels)
3. **Select "Add Files to 'LagAuditApp'"**
4. **Navigate to the file location**
5. **Select the file**
6. **Make sure "Add to target: LagAuditApp" is checked**
7. **Click "Add"**

## Alternative: Drag and Drop

1. **Open Finder and navigate to the project folder**
2. **Drag the file from Finder to the appropriate group in Xcode**
3. **Make sure "Copy items if needed" is checked**
4. **Make sure "Add to target: LagAuditApp" is checked**
5. **Click "Finish"**

## Verification

After adding the files, the project should compile successfully. The new architecture includes:

- **Centralized Routing** with `AppRouter` and `Route` enum
- **Single Source of Truth** with `AuditViewModel` for audit sessions
- **Autosave functionality** with debounced saving
- **Section-based navigation** with `AuditSection` enum
- **Modern SwiftUI navigation** with `NavigationSplitView` and `NavigationStack`

## Files Already Updated

The following files have been updated to work with the new architecture:

- `Views/ContentView.swift` - Main app structure with NavigationSplitView
- `Views/HomeView.swift` - Updated to use new routing
- `Views/HomeSidebar.swift` - Updated to use new routing  
- `Views/AuditShellView.swift` - Updated to use AuditViewModel
- `Views/FarmInfoView.swift` - Updated to use AuditViewModel
- `Views/MilkingTimeView.swift` - Updated to use AuditViewModel
- `Views/DetachersView.swift` - Updated to use AuditViewModel
- `Views/PulsatorsView.swift` - Updated to use AuditViewModel
- `Views/DiagnosticsView.swift` - Updated to use AuditViewModel
- `Views/RecommendationsView.swift` - Updated to use AuditViewModel
- `Views/OverviewView.swift` - Updated to use AuditViewModel
- `ViewModels/AuditDataManager.swift` - Updated to remove deprecated methods
- `Utilities/AppRouter.swift` - Enhanced with navigation methods
- `ViewModels/AuditViewModel.swift` - Enhanced with autosave and data management 