import SwiftUI

enum Route: Hashable {
    case home
    case newAudit(UUID)
    case editAudit(UUID)   // draft
    case history
    case settings
}

/// Shared across the app
@MainActor final class AppRouter: ObservableObject {
    @Published var path: [Route] = []
    
    func push(_ r: Route)  { path.append(r) }
    func popToRoot()       { path = [] }
    func pop()            { _ = path.popLast() }
    
    func navigateToNewAudit() {
        let auditID = UUID()
        push(.newAudit(auditID))
    }
    
    func navigateToEditAudit(_ auditID: UUID) {
        push(.editAudit(auditID))
    }
    
    func navigateToHistory() {
        push(.history)
    }
    
    func navigateToSettings() {
        push(.settings)
    }
} 