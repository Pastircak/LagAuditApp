import SwiftUI

// MARK: - Design System Documentation
/**
 * LAG AUDIT APP DESIGN SYSTEM
 * ===========================
 * 
 * This file serves as the single source of truth for all design patterns,
 * architectural decisions, and styling conventions used throughout the app.
 * 
 * PURPOSE:
 * - Ensure consistency across all views and components
 * - Provide clear guidelines for future development
 * - Enable AI agents to understand and follow established patterns
 * - Maintain the current high-quality design as the app evolves
 * 
 * USAGE:
 * - Reference this file when creating new views or components
 * - Use the provided constants and modifiers consistently
 * - Follow the architectural patterns documented here
 * - Test changes against these established patterns
 */

// MARK: - Color System
struct AppColors {
    // MARK: Primary Colors
    static let primary = Color.blue
    static let secondary = Color.orange
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // MARK: Semantic Colors (from Extensions.swift)
    static let systemBackground = Color.white
    static let secondarySystemBackground = Color.gray.opacity(0.1)
    static let tertiarySystemBackground = Color.gray.opacity(0.05)
    static let systemGray = Color.gray
    static let systemGray2 = Color.gray.opacity(0.8)
    static let systemGray3 = Color.gray.opacity(0.6)
    static let systemGray4 = Color.gray.opacity(0.4)
    static let systemGray5 = Color.gray.opacity(0.2)
    static let systemGray6 = Color.gray.opacity(0.1)
    
    // MARK: Status Colors
    static let normalStatus = Color.green
    static let warningStatus = Color.orange
    static let criticalStatus = Color.red
}

// MARK: - Typography System
struct AppTypography {
    // MARK: Font Sizes
    static let largeTitle = Font.largeTitle
    static let title = Font.title
    static let title2 = Font.title2
    static let title3 = Font.title3
    static let headline = Font.headline
    static let subheadline = Font.subheadline
    static let body = Font.body
    static let callout = Font.callout
    static let caption = Font.caption
    static let caption2 = Font.caption2
    
    // MARK: Font Weights
    static let bold = Font.Weight.bold
    static let semibold = Font.Weight.semibold
    static let medium = Font.Weight.medium
    static let regular = Font.Weight.regular
}

// MARK: - Spacing System
struct AppSpacing {
    // MARK: Standard Spacing Values
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    
    // MARK: Common Spacing Patterns
    static let cardPadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 20
    static let listItemSpacing: CGFloat = 12
    static let buttonSpacing: CGFloat = 16
}

// MARK: - Layout System
struct AppLayout {
    // MARK: Corner Radius Values
    static let smallRadius: CGFloat = 8
    static let mediumRadius: CGFloat = 12
    static let largeRadius: CGFloat = 16
    
    // MARK: Shadow Values
    static let cardShadow = Shadow(
        color: .black.opacity(0.1),
        radius: 8,
        x: 0,
        y: 4
    )
    
    static let subtleShadow = Shadow(
        color: .black.opacity(0.1),
        radius: 2,
        x: 0,
        y: 1
    )
    
    // MARK: Grid Configuration
    static let twoColumnGrid = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    static let threeColumnGrid = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
}

// MARK: - Shadow Structure
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifiers (Design System Implementation)
extension View {
    // MARK: Card Styling
    func cardStyle() -> some View {
        self
            .padding(AppSpacing.cardPadding)
            .background(AppColors.systemBackground)
            .cornerRadius(AppLayout.mediumRadius)
            .shadow(
                color: AppLayout.cardShadow.color,
                radius: AppLayout.cardShadow.radius,
                x: AppLayout.cardShadow.x,
                y: AppLayout.cardShadow.y
            )
    }
    
    func subtleCardStyle() -> some View {
        self
            .padding(AppSpacing.cardPadding)
            .background(AppColors.systemBackground)
            .cornerRadius(AppLayout.mediumRadius)
            .shadow(
                color: AppLayout.subtleShadow.color,
                radius: AppLayout.subtleShadow.radius,
                x: AppLayout.subtleShadow.x,
                y: AppLayout.subtleShadow.y
            )
    }
    
    // MARK: Section Styling
    func sectionStyle() -> some View {
        self
            .padding(AppSpacing.md)
            .background(AppColors.systemGray6)
            .cornerRadius(AppLayout.smallRadius)
    }
    
    // MARK: Standard Padding
    func standardPadding() -> some View {
        self.padding(AppSpacing.md)
    }
    
    func cardPadding() -> some View {
        self.padding(AppSpacing.cardPadding)
    }
}

// MARK: - Architectural Patterns
/**
 * ARCHITECTURAL PATTERNS
 * ======================
 * 
 * The app follows these established patterns:
 * 
 * 1. MVVM Architecture:
 *    - Views: Pure SwiftUI views with minimal logic
 *    - ViewModels: ObservableObject classes managing state
 *    - Models: Core Data entities for persistence
 * 
 * 2. Navigation Pattern:
 *    - AppRouter: Centralized navigation management
 *    - NavigationSplitView: Main app structure
 *    - NavigationStack: Detail view navigation
 *    - Sheet presentations: Modal interactions
 * 
 * 3. Data Flow Pattern:
 *    - AuditDataManager: Single source of truth for audit data
 *    - @Published properties: Reactive state management
 *    - Core Data integration: Persistent storage
 * 
 * 4. Component Pattern:
 *    - Reusable components in Components.swift
 *    - Consistent styling through View modifiers
 *    - Standardized spacing and layout
 */

// MARK: - Component Guidelines
/**
 * COMPONENT GUIDELINES
 * ====================
 * 
 * When creating new components, follow these guidelines:
 * 
 * 1. Use established color system (AppColors)
 * 2. Follow typography hierarchy (AppTypography)
 * 3. Use consistent spacing (AppSpacing)
 * 4. Apply standard corner radius (AppLayout)
 * 5. Use card styling for content containers
 * 6. Implement proper accessibility
 * 7. Follow SwiftUI best practices
 */

// MARK: - View Structure Guidelines
/**
 * VIEW STRUCTURE GUIDELINES
 * =========================
 * 
 * Standard view structure:
 * 
 * NavigationStack {
 *     VStack(spacing: AppSpacing.sectionSpacing) {
 *         // Header section
 *         VStack(spacing: AppSpacing.sm) {
 *             Text("Title")
 *                 .font(AppTypography.title)
 *                 .fontWeight(AppTypography.bold)
 *             
 *             Text("Subtitle")
 *                 .font(AppTypography.subheadline)
 *                 .foregroundColor(.secondary)
 *         }
 *         
 *         // Content section
 *         ScrollView {
 *             VStack(spacing: AppSpacing.md) {
 *                 // Content here
 *             }
 *             .standardPadding()
 *         }
 *         
 *         // Action section
 *         HStack {
 *             // Action buttons
 *         }
 *         .cardPadding()
 *     }
 *     .navigationTitle("Screen Title")
 * }
 */

// MARK: - Button Guidelines
/**
 * BUTTON GUIDELINES
 * =================
 * 
 * Standard button patterns:
 * 
 * 1. Primary Actions: .borderedProminent
 * 2. Secondary Actions: .bordered
 * 3. Destructive Actions: .bordered with .foregroundColor(.red)
 * 4. Card Buttons: Custom styling with cardStyle()
 * 5. Icon Buttons: Use system images with consistent sizing
 */

// MARK: - Form Guidelines
/**
 * FORM GUIDELINES
 * ===============
 * 
 * Standard form patterns:
 * 
 * 1. Use TextField with RoundedBorderTextFieldStyle()
 * 2. Group related fields in VStack with consistent spacing
 * 3. Use InfoRow component for label-value pairs
 * 4. Apply sectionStyle() to form sections
 * 5. Implement proper validation and error handling
 */

// MARK: - List Guidelines
/**
 * LIST GUIDELINES
 * ===============
 * 
 * Standard list patterns:
 * 
 * 1. Use List for data-driven content
 * 2. Group items in sections when appropriate
 * 3. Use consistent row styling
 * 4. Implement proper empty states
 * 5. Use searchable modifier for large lists
 */

// MARK: - Navigation Guidelines
/**
 * NAVIGATION GUIDELINES
 * =====================
 * 
 * Standard navigation patterns:
 * 
 * 1. Use AppRouter for programmatic navigation
 * 2. Implement proper back button behavior
 * 3. Use sheets for modal presentations
 * 4. Provide clear navigation titles
 * 5. Handle deep linking appropriately
 */

// MARK: - Error Handling Guidelines
/**
 * ERROR HANDLING GUIDELINES
 * =========================
 * 
 * Standard error handling patterns:
 * 
 * 1. Use @State for error state management
 * 2. Display errors with .alert modifier
 * 3. Provide clear, actionable error messages
 * 4. Implement proper loading states
 * 5. Handle network and data persistence errors
 */

// MARK: - Accessibility Guidelines
/**
 * ACCESSIBILITY GUIDELINES
 * ========================
 * 
 * Standard accessibility patterns:
 * 
 * 1. Use semantic colors and fonts
 * 2. Provide proper accessibility labels
 * 3. Implement VoiceOver support
 * 4. Use appropriate contrast ratios
 * 5. Support Dynamic Type
 */

// MARK: - Testing Guidelines
/**
 * TESTING GUIDELINES
 * ==================
 * 
 * Before implementing changes:
 * 
 * 1. Test on different device sizes
 * 2. Verify navigation flows
 * 3. Check accessibility features
 * 4. Validate data persistence
 * 5. Test error scenarios
 * 6. Compare with existing design patterns
 */

// MARK: - Migration Guidelines
/**
 * MIGRATION GUIDELINES
 * ====================
 * 
 * When updating the design system:
 * 
 * 1. Update this file first
 * 2. Test changes incrementally
 * 3. Maintain backward compatibility
 * 4. Document breaking changes
 * 5. Update related documentation
 */ 