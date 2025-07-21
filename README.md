# LagAuditApp

## SwiftUI Project Code Quality & Error Prevention Guide

### 1. Centralize Shared Types and Enums
- Define enums, models, and shared types in a single, dedicated file (e.g., `AuditTypes.swift`).
- Never duplicate type definitions across files.
- When updating an enum, search for all usages and update them together.

### 2. Avoid Duplicate Type Definitions
- Only one definition per type (struct, enum, class) per module.
- Reference the shared definition everywhere it’s needed.

### 3. Keep Enum Cases and Usages in Sync
- Use `.allCases` and exhaustive `switch` statements to catch missing cases at compile time.
- When adding or removing cases, update all usages in the codebase.

### 4. Scaffold All Referenced Views
- If a view is referenced in navigation or elsewhere, create at least a stub implementation (e.g., `DraftsView`, `HistoryView`).
- This prevents 'Cannot find in scope' errors and keeps navigation working.

### 5. SwiftUI View Builder Best Practices
- When passing multiple views to a closure, always wrap them in a container (`VStack`, `HStack`, or `Group`).
- This avoids 'Type () cannot conform to View' errors.

### 6. Handle Function Results and Unused Variables
- Use `@discardableResult` for functions where the result may be ignored.
- Prefix unused results with `_ =` to silence warnings.
- Remove or use variables that are assigned but never used.

### 7. Import Only Modules, Not Files
- Use `import Foundation`, `import SwiftUI`, etc.
- Do not try to import your own files as modules (e.g., `import Utilities.AuditTypes` is incorrect).

### 8. General Refactoring Tips
- When refactoring, search for all usages of a type or case and update them together.
- Run a clean build after major changes to catch errors early.

### 9. Code Review Checklist
- [ ] Are all shared types/enums defined in one place?
- [ ] Are all referenced views implemented (even as stubs)?
- [ ] Are all enum cases and usages in sync?
- [ ] Are all SwiftUI view builder closures returning a single View?
- [ ] Are there any unused variables or function results?
- [ ] Are only modules being imported, not files?
- [ ] Does the project build cleanly with no warnings or errors?

---

Following this guide will help keep the codebase robust, maintainable, and error-free as the project grows. 