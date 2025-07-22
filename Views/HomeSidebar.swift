import SwiftUI

struct HomeSidebarView: View {
    @ObservedObject var dataManager: AuditDataManager
    @ObservedObject var router: AppRouter
    @State private var showingDraftsSheet = false
    
    var body: some View {
        List {
            Section {
                Button {
                    router.navigateToNewAudit()
                } label: {
                    Label("New Audit", systemImage: "plus.circle")
                        .font(.headline)
                }
                
                Button {
                    showingDraftsSheet = true
                } label: {
                    Label("Drafts (resume)", systemImage: "doc.text")
                        .font(.headline)
                }
            }
            
            Section {
                Button {
                    router.navigateToHistory()
                } label: {
                    Label("History (per farm)", systemImage: "clock")
                        .font(.headline)
                }
                
                Button {
                    router.navigateToSettings()
                } label: {
                    Label("Settings", systemImage: "gear")
                        .font(.headline)
                }
            }
        }
        .navigationTitle("LagAudit")
        .sheet(isPresented: $showingDraftsSheet) {
            DraftListView(dataManager: dataManager, router: router)
        }
    }
}

struct DraftListView: View {
    @ObservedObject var dataManager: AuditDataManager
    @ObservedObject var router: AppRouter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.drafts) { draft in
                    Button {
                        if let auditID = draft.id {
                            router.navigateToEditAudit(auditID)
                        }
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(draft.farmName ?? "Unknown Farm")
                                .font(.headline)
                            
                            Text("Technician: \(draft.technician ?? "Unknown")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let date = draft.updatedAt {
                                Text("Last updated: \(date, style: .relative)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Drafts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            dataManager.loadDrafts()
        }
    }
} 