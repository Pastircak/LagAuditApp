# LagAuditApp Quick Reference

## 🚀 Quick Start
1. **Read**: `DEVELOPMENT_GUIDE.md` for comprehensive overview
2. **Reference**: `Utilities/DesignSystem.swift` for styling
3. **Follow**: `Utilities/ArchitectureGuide.swift` for patterns
4. **Apply**: `Utilities/StyleGuide.swift` for visual consistency

## 📁 Key Files

### Documentation
- `DEVELOPMENT_GUIDE.md` - Complete development guide
- `DESIGN_CHECKPOINT.md` - Current design state
- `QUICK_REFERENCE.md` - This file

### Design System
- `Utilities/DesignSystem.swift` - Colors, typography, spacing, layouts
- `Utilities/StyleGuide.swift` - Visual patterns and UI conventions
- `Utilities/ArchitectureGuide.swift` - Architectural patterns

### Core App Files
- `Views/Components.swift` - Reusable UI components
- `Utilities/AppRouter.swift` - Navigation management
- `ViewModels/AuditDataManager.swift` - Data management
- `Utilities/Extensions.swift` - SwiftUI extensions

## 🎨 Design System Quick Reference

### Colors
```swift
AppColors.primary      // Blue
AppColors.secondary    // Orange
AppColors.success      // Green
AppColors.error        // Red
AppColors.systemBackground // White
```

### Typography
```swift
AppTypography.title    // Large titles
AppTypography.headline // Section headers
AppTypography.body     // Body text
AppTypography.caption  // Small text
```

### Spacing
```swift
AppSpacing.sm          // 8pt
AppSpacing.md          // 16pt
AppSpacing.lg          // 20pt
AppSpacing.xl          // 24pt
```

### Layout
```swift
AppLayout.twoColumnGrid    // 2-column grid
AppLayout.mediumRadius     // 12pt corner radius
AppLayout.cardShadow       // Standard shadow
```

## 🏗️ Architecture Quick Reference

### View Structure
```swift
struct MyView: View {
    @ObservedObject var dataManager: AuditDataManager
    @ObservedObject var router: AppRouter
    @State private var localState = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.sectionSpacing) {
                // Content
            }
            .standardPadding()
            .navigationTitle("Title")
        }
    }
}
```

### Navigation
```swift
// Navigate programmatically
router.navigateToNewAudit()
router.push(.history)
router.popToRoot()
```

### State Management
```swift
// Global state
@ObservedObject var dataManager: AuditDataManager

// Local state
@State private var localValue = ""

// Environment
@Environment(\.managedObjectContext) private var viewContext
```

## 🎯 Common Patterns

### Card Styling
```swift
VStack {
    // Content
}
.cardStyle()           // Standard card
.subtleCardStyle()     // Subtle card
.sectionStyle()        // Section background
```

### Error Handling
```swift
@State private var showingError = false
@State private var errorMessage = ""

.alert("Error", isPresented: $showingError) {
    Button("OK") { }
} message: {
    Text(errorMessage)
}
```

### Loading States
```swift
@Published var isLoading = false

if isLoading {
    LoadingView(message: "Loading...")
} else {
    // Content
}
```

## 🔧 Development Workflow

### 1. Planning
- [ ] Read relevant documentation
- [ ] Plan implementation approach
- [ ] Consider design impact

### 2. Implementation
- [ ] Follow file organization patterns
- [ ] Use design system constants
- [ ] Apply architectural patterns
- [ ] Implement proper error handling

### 3. Testing
- [ ] Visual consistency check
- [ ] Functional testing
- [ ] Accessibility testing
- [ ] Performance testing

### 4. Review
- [ ] Code review against patterns
- [ ] Design review for consistency
- [ ] Documentation updates

## 🚨 Troubleshooting

### Design Issues
- **Problem**: Inconsistent styling
- **Solution**: Use `AppColors`, `AppTypography`, `AppSpacing`
- **Check**: `Utilities/DesignSystem.swift`

### Navigation Issues
- **Problem**: Navigation not working
- **Solution**: Use `AppRouter` methods
- **Check**: `Utilities/AppRouter.swift`

### State Issues
- **Problem**: State not updating
- **Solution**: Use appropriate `@Published`, `@State`, `@ObservedObject`
- **Check**: `Utilities/ArchitectureGuide.swift`

### Performance Issues
- **Problem**: App feels slow
- **Solution**: Follow performance guidelines
- **Check**: `DEVELOPMENT_GUIDE.md` performance section

## 🔄 Checkpoint System

### Restore to Design Checkpoint
```bash
./restore_design_checkpoint.sh
```

### Manual Restore
```bash
git checkout design-checkpoint-v1.0
```

### Compare Changes
```bash
git diff design-checkpoint-v1.0
```

## 📋 Checklist for New Features

### Before Starting
- [ ] Read `DEVELOPMENT_GUIDE.md`
- [ ] Review `ArchitectureGuide.swift`
- [ ] Check `DesignSystem.swift`
- [ ] Plan file organization

### During Development
- [ ] Use design system constants
- [ ] Follow architectural patterns
- [ ] Implement proper error handling
- [ ] Add loading states
- [ ] Test on different devices

### Before Completion
- [ ] Visual consistency check
- [ ] Functional testing
- [ ] Accessibility testing
- [ ] Performance testing
- [ ] Documentation updates

## 🎯 Best Practices

### Code Quality
- Follow established patterns consistently
- Write self-documenting code
- Use clear, descriptive names
- Document complex logic

### Design Consistency
- Use design system constants
- Follow established visual patterns
- Test on multiple devices
- Maintain accessibility standards

### Performance
- Optimize for user experience
- Minimize unnecessary updates
- Use appropriate data structures
- Monitor performance metrics

## 📞 Getting Help

1. **Check Documentation**: Review relevant guide files
2. **Compare with Existing**: Look at similar implementations
3. **Use Checkpoint System**: Revert if needed
4. **Test Incrementally**: Make small changes and test

## 🎉 Success Metrics

- ✅ New features integrate seamlessly
- ✅ Design consistency maintained
- ✅ Performance remains smooth
- ✅ Accessibility standards met
- ✅ User experience enhanced

---

**Remember**: The goal is to build upon the solid foundation while maintaining the professional, clean aesthetic that users appreciate. 