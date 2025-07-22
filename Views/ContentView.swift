import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager: AuditDataManager
    @StateObject private var router = AppRouter()
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _dataManager = StateObject(wrappedValue: AuditDataManager(context: context))
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            HomeSidebarView(dataManager: dataManager, router: router)
        } detail: {
            // Detail View
            NavigationStack(path: $router.path) {
                HomeView(dataManager: dataManager, router: router)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .home:
                            HomeView(dataManager: dataManager, router: router)
                        case .newAudit(let auditID):
                            AuditShellView(auditID: auditID, dataManager: dataManager, router: router)
                        case .editAudit(let auditID):
                            AuditShellView(auditID: auditID, dataManager: dataManager, router: router)
                        case .history:
                            AuditHistoryView()
                        case .settings:
                            SettingsView()
                        }
                    }
            }
        }
        .environmentObject(router)
    }
}
