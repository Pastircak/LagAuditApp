import SwiftUI

struct DraftsView: View {
    @ObservedObject var dataManager: AuditDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    @State private var draftToDelete: Audit?
    @State private var showingResumeAlert = false
    @State private var draftToResume: Audit?
    @State private var shouldNavigateToAudit = false
    
    var body: some View {
        NavigationView {
            Group {
                if dataManager.drafts.isEmpty {
                    emptyStateView
                } else {
                    draftsListView
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
        .background(
            NavigationLink(
                destination: AuditWorkspaceView(auditManager: dataManager),
                isActive: $shouldNavigateToAudit
            ) {
                EmptyView()
            }
        )
        .onAppear {
            print("DraftsView appeared, drafts count: \(dataManager.drafts.count)")
            dataManager.loadDrafts()
        }
        .onChange(of: dataManager.drafts.count) { newCount in
            print("Drafts count changed to: \(newCount)")
        }
        .alert("Delete Draft", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { 
                print("Delete cancelled")
            }
            Button("Delete", role: .destructive) {
                print("Delete confirmed for draft: \(draftToDelete?.farmName ?? "Unknown")")
                if let draft = draftToDelete {
                    dataManager.deleteDraft(draft)
                }
            }
        } message: {
            Text("Are you sure you want to delete this draft? This action cannot be undone.")
        }
        .alert("Resume Draft", isPresented: $showingResumeAlert) {
            Button("Cancel", role: .cancel) { 
                print("Resume cancelled")
            }
            Button("Resume") {
                print("Resume confirmed for draft: \(draftToResume?.farmName ?? "Unknown")")
                if let draft = draftToResume {
                    dataManager.loadDraft(draft)
                    shouldNavigateToAudit = true
                    dismiss()
                }
            }
        } message: {
            Text("This will load the draft data into the current audit session. Any unsaved changes will be lost.")
        }
        .onAppear {
            dataManager.loadDrafts()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Drafts")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Drafts will appear here when you save incomplete audits.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Debug info
            Text("Debug: \(dataManager.drafts.count) drafts in array")
                .font(.caption)
                .foregroundColor(.red)
            
            // Test button for debugging
            Button("Create Test Draft") {
                dataManager.createTestDraft()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
            
            // Refresh button
            Button("Refresh Drafts") {
                dataManager.loadDrafts()
            }
            .buttonStyle(.bordered)
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var draftsListView: some View {
        List {
            ForEach(dataManager.drafts, id: \.id) { draft in
                DraftRowView(
                    draft: draft,
                    onResume: {
                        print("Resume button tapped for draft: \(draft.farmName ?? "Unknown")")
                        draftToResume = draft
                        showingResumeAlert = true
                    },
                    onDelete: {
                        print("Delete button tapped for draft: \(draft.farmName ?? "Unknown")")
                        draftToDelete = draft
                        showingDeleteAlert = true
                    }
                )
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct DraftRowView: View {
    let draft: Audit
    let onResume: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(draft.farmName ?? "Unknown Farm")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("Technician: \(draft.technician ?? "Unknown")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let date = draft.updatedAt {
                        Text("Last updated: \(date, style: .relative)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: onResume) {
                        Label("Resume", systemImage: "arrow.clockwise")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onDelete) {
                        Label("Delete", systemImage: "trash")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if let notes = draft.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DraftsView(dataManager: AuditDataManager(context: PersistenceController.preview.container.viewContext))
} 