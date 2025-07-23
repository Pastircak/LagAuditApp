import SwiftUI

// MARK: - LagAuditApp Style Guide
/**
 * LAG AUDIT APP STYLE GUIDE
 * =========================
 * 
 * This file documents all visual patterns, UI conventions, and design decisions
 * that create the distinctive look and feel of the LagAuditApp.
 * 
 * PURPOSE:
 * - Maintain visual consistency across all screens
 * - Provide clear guidelines for UI design decisions
 * - Ensure new features match the existing aesthetic
 * - Create a cohesive user experience
 * 
 * USAGE:
 * - Reference this guide when creating new UI elements
 * - Use the provided constants and patterns consistently
 * - Test visual changes against established patterns
 * - Maintain the professional, clean aesthetic
 */

// MARK: - Visual Identity
/**
 * VISUAL IDENTITY
 * ===============
 * 
 * The app's visual identity is characterized by:
 * 
 * 1. PROFESSIONAL AESTHETIC
 *    - Clean, modern interface design
 *    - Consistent use of system fonts and colors
 *    - Subtle shadows and depth
 *    - Professional color palette
 * 
 * 2. CARD-BASED LAYOUT
 *    - Content organized in distinct cards
 *    - Consistent card styling and spacing
 *    - Clear visual hierarchy
 *    - Proper use of white space
 * 
 * 3. RESPONSIVE DESIGN
 *    - Adapts to different device sizes
 *    - iPad-optimized layouts
 *    - Consistent experience across devices
 *    - Proper use of available space
 */

// MARK: - Color Palette
/**
 * COLOR PALETTE
 * =============
 * 
 * The app uses a carefully selected color palette:
 * 
 * PRIMARY COLORS:
 * - Blue: Primary actions, navigation, success states
 * - Orange: Secondary actions, warnings, highlights
 * - Green: Success states, positive feedback
 * - Red: Error states, destructive actions
 * 
 * NEUTRAL COLORS:
 * - White: Primary backgrounds, cards
 * - Gray variations: Secondary backgrounds, borders, text
 * - Black: Primary text, strong emphasis
 * 
 * SEMANTIC COLORS:
 * - Normal: Green (good/acceptable values)
 * - Warning: Orange (attention needed)
 * - Critical: Red (immediate action required)
 */

// MARK: - Typography System
/**
 * TYPOGRAPHY SYSTEM
 * =================
 * 
 * The app uses a hierarchical typography system:
 * 
 * HEADINGS:
 * - Large Title: Main page titles (Welcome to LagAudit)
 * - Title: Section headers, major content areas
 * - Title2: Subsection headers, card titles
 * - Title3: Minor section headers
 * 
 * BODY TEXT:
 * - Headline: Important body text, emphasis
 * - Subheadline: Secondary information, descriptions
 * - Body: Primary content text
 * - Callout: Highlighted information
 * 
 * SUPPORTING TEXT:
 * - Caption: Small supporting text, metadata
 * - Caption2: Very small text, fine details
 * 
 * FONT WEIGHTS:
 * - Bold: Primary headings, important information
 * - Semibold: Secondary headings, emphasis
 * - Medium: Important body text
 * - Regular: Standard body text
 */

// MARK: - Spacing System
/**
 * SPACING SYSTEM
 * ==============
 * 
 * Consistent spacing creates visual rhythm:
 * 
 * MICRO SPACING (4-8pt):
 * - 4pt: Minimal spacing between related elements
 * - 8pt: Standard spacing between elements
 * 
 * SMALL SPACING (12-16pt):
 * - 12pt: Spacing between list items
 * - 16pt: Standard section spacing
 * 
 * MEDIUM SPACING (20-24pt):
 * - 20pt: Spacing between major sections
 * - 24pt: Card padding, button spacing
 * 
 * LARGE SPACING (32-40pt):
 * - 32pt: Major section separation
 * - 40pt: Page-level spacing
 */

// MARK: - Layout Patterns
/**
 * LAYOUT PATTERNS
 * ===============
 * 
 * Standard layout patterns used throughout the app:
 * 
 * 1. CARD LAYOUT
 *    - Content organized in distinct cards
 *    - Consistent padding (24pt)
 *    - Subtle shadows for depth
 *    - Rounded corners (12pt radius)
 * 
 * 2. GRID LAYOUT
 *    - Two-column grid for main actions
 *    - Three-column grid for data display
 *    - Consistent spacing between items
 *    - Responsive to device size
 * 
 * 3. LIST LAYOUT
 *    - Standard list styling
 *    - Consistent row heights
 *    - Clear visual separation
 *    - Proper empty states
 * 
 * 4. FORM LAYOUT
 *    - Grouped fields in sections
 *    - Consistent field spacing
 *    - Clear labels and validation
 *    - Proper button placement
 */

// MARK: - Component Styling
/**
 * COMPONENT STYLING
 * =================
 * 
 * Standard styling for common components:
 * 
 * 1. CARDS
 *    - Background: White
 *    - Padding: 24pt
 *    - Corner radius: 12pt
 *    - Shadow: Subtle drop shadow
 *    - Border: None (clean look)
 * 
 * 2. BUTTONS
 *    - Primary: .borderedProminent (blue)
 *    - Secondary: .bordered (gray)
 *    - Destructive: .bordered with red text
 *    - Card buttons: Custom styling with cardStyle()
 * 
 * 3. TEXT FIELDS
 *    - Style: RoundedBorderTextFieldStyle()
 *    - Consistent padding and sizing
 *    - Clear validation states
 *    - Proper accessibility labels
 * 
 * 4. LISTS
 *    - Standard list styling
 *    - Consistent row heights
 *    - Clear section headers
 *    - Proper empty states
 */

// MARK: - Visual Hierarchy
/**
 * VISUAL HIERARCHY
 * ================
 * 
 * Clear visual hierarchy guides user attention:
 * 
 * 1. PRIMARY ELEMENTS
 *    - Large titles and headings
 *    - Primary action buttons
 *    - Important data displays
 *    - Navigation elements
 * 
 * 2. SECONDARY ELEMENTS
 *    - Supporting text and descriptions
 *    - Secondary actions
 *    - Metadata and details
 *    - Navigation breadcrumbs
 * 
 * 3. TERTIARY ELEMENTS
 *    - Fine details and metadata
 *    - Disabled or inactive elements
 *    - Background information
 *    - Subtle UI elements
 */

// MARK: - Interactive Elements
/**
 * INTERACTIVE ELEMENTS
 * ====================
 * 
 * Consistent interaction patterns:
 * 
 * 1. BUTTONS
 *    - Clear visual feedback on tap
 *    - Consistent sizing and spacing
 *    - Proper accessibility labels
 *    - Loading states for async actions
 * 
 * 2. NAVIGATION
 *    - Clear navigation indicators
 *    - Consistent back button behavior
 *    - Proper breadcrumb navigation
 *    - Smooth transitions
 * 
 * 3. FORMS
 *    - Real-time validation feedback
 *    - Clear error messages
 *    - Proper keyboard handling
 *    - Auto-save where appropriate
 * 
 * 4. LISTS
 *    - Clear selection states
 *    - Swipe actions where appropriate
 *    - Proper empty states
 *    - Smooth scrolling
 */

// MARK: - Status Indicators
/**
 * STATUS INDICATORS
 * =================
 * 
 * Consistent status and feedback patterns:
 * 
 * 1. SUCCESS STATES
 *    - Green color for positive feedback
 *    - Checkmark icons for completion
 *    - Clear success messages
 *    - Automatic progression where appropriate
 * 
 * 2. WARNING STATES
 *    - Orange color for attention needed
 *    - Warning icons (exclamation triangle)
 *    - Clear warning messages
 *    - Suggested actions
 * 
 * 3. ERROR STATES
 *    - Red color for errors
 *    - Error icons (X mark)
 *    - Clear error messages
 *    - Recovery options
 * 
 * 4. LOADING STATES
 *    - Progress indicators
 *    - Loading messages
 *    - Disabled interactions during loading
 *    - Timeout handling
 */

// MARK: - Empty States
/**
 * EMPTY STATES
 * ============
 * 
 * Consistent empty state design:
 * 
 * 1. VISUAL ELEMENTS
 *    - Large, descriptive icons
 *    - Clear, helpful messages
 *    - Action buttons when appropriate
 *    - Consistent styling
 * 
 * 2. MESSAGING
 *    - Friendly, helpful tone
 *    - Clear explanation of what's missing
 *    - Suggested actions when possible
 *    - Consistent language patterns
 * 
 * 3. ACTIONS
 *    - Primary action to resolve empty state
 *    - Secondary actions for exploration
 *    - Clear call-to-action buttons
 *    - Proper button styling
 */

// MARK: - Data Visualization
/**
 * DATA VISUALIZATION
 * ==================
 * 
 * Consistent data display patterns:
 * 
 * 1. STATISTICS CARDS
 *    - Large, prominent numbers
 *    - Clear labels and units
 *    - Color-coded for status
 *    - Consistent card styling
 * 
 * 2. PROGRESS INDICATORS
 *    - Linear progress bars
 *    - Percentage displays
 *    - Color-coded progress states
 *    - Clear progress labels
 * 
 * 3. LISTS AND TABLES
 *    - Consistent row styling
 *    - Clear column headers
 *    - Proper data alignment
 *    - Sortable where appropriate
 * 
 * 4. CHARTS AND GRAPHS
 *    - Consistent color schemes
 *    - Clear axis labels
 *    - Proper data scaling
 *    - Interactive where appropriate
 */

// MARK: - Accessibility Design
/**
 * ACCESSIBILITY DESIGN
 * ====================
 * 
 * Inclusive design principles:
 * 
 * 1. VISUAL ACCESSIBILITY
 *    - High contrast ratios
 *    - Clear visual hierarchy
 *    - Consistent color usage
 *    - Proper text sizing
 * 
 * 2. INTERACTION ACCESSIBILITY
 *    - Adequate touch targets (44pt minimum)
 *    - Clear focus indicators
 *    - Alternative input methods
 *    - VoiceOver compatibility
 * 
 * 3. CONTENT ACCESSIBILITY
 *    - Semantic markup
 *    - Clear, descriptive labels
 *    - Proper heading hierarchy
 *    - Alternative text for images
 * 
 * 4. COGNITIVE ACCESSIBILITY
 *    - Clear, simple language
 *    - Consistent navigation patterns
 *    - Predictable interactions
 *    - Error prevention
 */

// MARK: - Responsive Design
/**
 * RESPONSIVE DESIGN
 * =================
 * 
 * Adaptable layout patterns:
 * 
 * 1. DEVICE ADAPTATION
 *    - iPhone layouts (compact)
 *    - iPad layouts (expanded)
 *    - Landscape/portrait orientation
 *    - Different screen densities
 * 
 * 2. LAYOUT ADJUSTMENTS
 *    - Flexible grid systems
 *    - Adaptive spacing
 *    - Responsive typography
 *    - Conditional content display
 * 
 * 3. NAVIGATION ADAPTATION
 *    - Tab bar on iPhone
 *    - Sidebar on iPad
 *    - Modal presentations
 *    - Deep linking support
 * 
 * 4. CONTENT ADAPTATION
 *    - Responsive images
 *    - Adaptive text sizing
 *    - Flexible content containers
 *    - Proper overflow handling
 */

// MARK: - Animation and Transitions
/**
 * ANIMATION AND TRANSITIONS
 * =========================
 * 
 * Subtle, purposeful animations:
 * 
 * 1. PAGE TRANSITIONS
 *    - Smooth navigation transitions
 *    - Consistent timing and easing
 *    - Proper loading states
 *    - Error state transitions
 * 
 * 2. INTERACTION FEEDBACK
 *    - Button press animations
 *    - Form validation feedback
 *    - Loading state animations
 *    - Success/error transitions
 * 
 * 3. CONTENT ANIMATIONS
 *    - List item animations
 *    - Card appearance animations
 *    - Progress indicator animations
 *    - Status change animations
 * 
 * 4. ANIMATION PRINCIPLES
 *    - Subtle and purposeful
 *    - Consistent timing
 *    - Proper easing curves
 *    - Performance conscious
 */

// MARK: - Iconography
/**
 * ICONOGRAPHY
 * ===========
 * 
 * Consistent icon usage:
 * 
 * 1. SYSTEM ICONS
 *    - Use SF Symbols consistently
 *    - Appropriate icon weights
 *    - Consistent sizing
 *    - Proper accessibility labels
 * 
 * 2. ICON SIZING
 *    - Small: 16pt (captions, fine details)
 *    - Medium: 24pt (body text, buttons)
 *    - Large: 48pt (cards, main actions)
 *    - Extra Large: 60pt (success states)
 * 
 * 3. ICON COLORS
 *    - Primary: Blue for main actions
 *    - Secondary: Orange for secondary actions
 *    - Success: Green for positive states
 *    - Error: Red for error states
 *    - Neutral: Gray for inactive states
 * 
 * 4. ICON PLACEMENT
 *    - Consistent positioning
 *    - Proper spacing from text
 *    - Clear visual alignment
 *    - Appropriate touch targets
 */

// MARK: - Brand Elements
/**
 * BRAND ELEMENTS
 * ==============
 * 
 * Consistent brand representation:
 * 
 * 1. LOGO USAGE
 *    - Consistent logo placement
 *    - Proper logo sizing
 *    - Clear logo visibility
 *    - Appropriate logo contexts
 * 
 * 2. COLOR CONSISTENCY
 *    - Brand color usage
 *    - Consistent color application
 *    - Proper color contrast
 *    - Accessible color combinations
 * 
 * 3. TYPOGRAPHY CONSISTENCY
 *    - Brand font usage
 *    - Consistent text styling
 *    - Proper font hierarchy
 *    - Readable text sizing
 * 
 * 4. VISUAL TONE
 *    - Professional appearance
 *    - Clean, modern aesthetic
 *    - Consistent visual language
 *    - Appropriate for target audience
 */

// MARK: - Implementation Guidelines
/**
 * IMPLEMENTATION GUIDELINES
 * =========================
 * 
 * Guidelines for implementing the style guide:
 * 
 * 1. CONSISTENCY
 *    - Use established patterns consistently
 *    - Apply spacing and typography rules
 *    - Follow color usage guidelines
 *    - Maintain visual hierarchy
 * 
 * 2. TESTING
 *    - Test on different device sizes
 *    - Verify accessibility compliance
 *    - Check color contrast ratios
 *    - Validate interaction patterns
 * 
 * 3. ITERATION
 *    - Gather user feedback
 *    - Refine based on usage patterns
 *    - Update style guide as needed
 *    - Maintain backward compatibility
 * 
 * 4. DOCUMENTATION
 *    - Update style guide for changes
 *    - Document new patterns
 *    - Provide implementation examples
 *    - Share with development team
 */

// MARK: - Style Guide Constants
/**
 * STYLE GUIDE CONSTANTS
 * =====================
 * 
 * Use these constants to maintain consistency:
 */

// MARK: - Standard Sizes
struct StandardSizes {
    static let iconSmall: CGFloat = 16
    static let iconMedium: CGFloat = 24
    static let iconLarge: CGFloat = 48
    static let iconExtraLarge: CGFloat = 60
    
    static let buttonHeight: CGFloat = 44
    static let cardPadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 20
    static let listItemSpacing: CGFloat = 12
}

// MARK: - Standard Durations
struct StandardDurations {
    static let quick: Double = 0.2
    static let standard: Double = 0.3
    static let slow: Double = 0.5
}

// MARK: - Standard Easing
struct StandardEasing {
    static let easeInOut = Animation.easeInOut(duration: StandardDurations.standard)
    static let easeOut = Animation.easeOut(duration: StandardDurations.standard)
    static let easeIn = Animation.easeIn(duration: StandardDurations.standard)
}

// MARK: - Style Guide Modifiers
extension View {
    func standardCardStyle() -> some View {
        self
            .padding(StandardSizes.cardPadding)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(
                color: .black.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
    }
    
    func standardButtonStyle() -> some View {
        self
            .frame(height: StandardSizes.buttonHeight)
            .buttonStyle(.borderedProminent)
    }
    
    func standardIconStyle(size: CGFloat = StandardSizes.iconMedium) -> some View {
        self
            .font(.system(size: size))
            .foregroundColor(.blue)
    }
} 