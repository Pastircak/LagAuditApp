import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: AuditWorkspaceView()) {
                    Label("New Audit", systemImage: "plus.circle")
                }
                NavigationLink(destination: DraftsView()) {
                    Label("Drafts (resume)", systemImage: "doc.text")
                }
                NavigationLink(destination: HistoryView()) {
                    Label("History (per farm)", systemImage: "clock")
                }
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gear")
                }
            }
            .navigationTitle("LagAudit")
        }
    }
} 