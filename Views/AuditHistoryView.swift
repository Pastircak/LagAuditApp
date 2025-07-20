import SwiftUI

struct AuditHistoryView: View {
    @StateObject private var dataManager: AuditDataManager
    @State private var selectedFarm: Farm?
    @State private var showingFarmFilter = false
    @State private var searchText = ""
    @State private var showingAuditDetail = false
    @State private var selectedAudit: Audit?
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _dataManager = StateObject(wrappedValue: AuditDataManager(context: context))
    }
    
    var filteredAudits: [Audit] {
        var audits = dataManager.audits
        
        // Filter by selected farm
        if let farm = selectedFarm {
            audits = audits.filter { $0.farmId == farm.id?.uuidString }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            audits = audits.filter { audit in
                audit.farmName?.localizedCaseInsensitiveContains(searchText) == true ||
                audit.technician?.localizedCaseInsensitiveContains(searchText) == true ||
                audit.notes?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        return audits
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Statistics header
                if !dataManager.audits.isEmpty {
                    statisticsHeader
                }
                
                // Audit list
                if dataManager.isLoading {
                    ProgressView("Loading audits...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredAudits.isEmpty {
                    emptyStateView
                } else {
                    auditList
                }
            }
            .navigationTitle("Audit History")
            .searchable(text: $searchText, prompt: "Search audits")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Filter") {
                        showingFarmFilter = true
                    }
                }
            }
            .sheet(isPresented: $showingFarmFilter) {
                FarmFilterView(selectedFarm: $selectedFarm, dataManager: dataManager)
            }
            .sheet(isPresented: $showingAuditDetail) {
                if let audit = selectedAudit {
                    AuditDetailView(audit: audit, dataManager: dataManager)
                }
            }
        }
    }
    
    private var statisticsHeader: some View {
        let stats = dataManager.getAuditStatistics(for: selectedFarm)
        
        return VStack(spacing: 12) {
            HStack {
                Text("Overview")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if selectedFarm != nil {
                    Button("Clear Filter") {
                        selectedFarm = nil
                    }
                    .font(.caption)
                }
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Audits",
                    value: "\(stats.totalAudits)",
                    color: Color.blue
                )
                
                StatCard(
                    title: "Critical Issues",
                    value: "\(stats.criticalIssues)",
                    color: Color.red
                )
                
                StatCard(
                    title: "Warnings",
                    value: "\(stats.warningIssues)",
                    color: Color.orange
                )
                
                StatCard(
                    title: "Normal",
                    value: "\(stats.normalReadings)",
                    color: Color.green
                )
            }
        }
        .padding()
        .background(Color.systemGray6)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(dataManager.audits.isEmpty ? "No Audits Yet" : "No Matching Audits")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(dataManager.audits.isEmpty ? 
                 "Start your first audit to see it here" : 
                 "Try adjusting your search or filter criteria")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var auditList: some View {
        List {
            ForEach(filteredAudits, id: \.id) { audit in
                AuditRowView(audit: audit, dataManager: dataManager)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedAudit = audit
                        showingAuditDetail = true
                    }
            }
            .onDelete(perform: deleteAudits)
        }
    }
    
    private func deleteAudits(offsets: IndexSet) {
        for index in offsets {
            let audit = filteredAudits[index]
            do {
                try dataManager.deleteAudit(audit)
            } catch {
                print("Error deleting audit: \(error)")
            }
        }
    }
}

struct AuditRowView: View {
    let audit: Audit
    let dataManager: AuditDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(audit.farmName ?? "Unknown Farm")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if let date = audit.date {
                        Text(DateFormatter.auditDate.string(from: date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let technician = audit.technician {
                        Text(technician)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    auditStatusBadge
                }
            }
            
            // Quick summary of issues
            if let entries = audit.entries?.allObjects as? [AuditEntry] {
                let criticalCount = entries.filter { $0.status == "Critical" }.count
                let warningCount = entries.filter { $0.status == "Low" || $0.status == "High" }.count
                
                if criticalCount > 0 || warningCount > 0 {
                    HStack(spacing: 8) {
                        if criticalCount > 0 {
                            Label("\(criticalCount) Critical", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        if warningCount > 0 {
                            Label("\(warningCount) Warnings", systemImage: "exclamationmark.triangle")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var auditStatusBadge: some View {
        let entries = audit.entries?.allObjects as? [AuditEntry] ?? []
        let hasCritical = entries.contains { $0.status == "Critical" }
        let hasWarnings = entries.contains { $0.status == "Low" || $0.status == "High" }
        
        let status: (text: String, color: Color) = {
            if hasCritical {
                return ("Critical", .red)
            } else if hasWarnings {
                return ("Warnings", .orange)
            } else {
                return ("Normal", .green)
            }
        }()
        
        return Text(status.text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.1))
            .cornerRadius(4)
    }
}

struct FarmFilterView: View {
    @Binding var selectedFarm: Farm?
    @ObservedObject var dataManager: AuditDataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("All Farms") {
                        selectedFarm = nil
                        dismiss()
                    }
                    .foregroundColor(selectedFarm == nil ? .blue : .primary)
                }
                
                Section("Farms") {
                    ForEach(dataManager.farms, id: \.id) { farm in
                        Button(farm.name ?? "Unknown Farm") {
                            selectedFarm = farm
                            dismiss()
                        }
                        .foregroundColor(selectedFarm?.id == farm.id ? .blue : .primary)
                    }
                }
            }
            .navigationTitle("Filter by Farm")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AuditDetailView: View {
    let audit: Audit
    let dataManager: AuditDataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Audit header
                    auditHeader
                    
                    // Statistics
                    auditStatistics
                    
                    // Detailed entries
                    auditEntries
                    
                    // Notes
                    if let notes = audit.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        auditNotes(notes)
                    }
                }
                .padding()
            }
            .navigationTitle("Audit Details")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var auditHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Audit Information")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Farm", value: audit.farmName ?? "Unknown")
                InfoRow(label: "Technician", value: audit.technician ?? "Unknown")
                if let date = audit.date {
                    InfoRow(label: "Date", value: DateFormatter.auditDate.string(from: date))
                }
            }
        }
        .padding()
        .background(Color.systemGray6)
        .cornerRadius(8)
    }
    
    private var auditStatistics: some View {
        let entries = dataManager.getAuditEntries(for: audit)
        let criticalCount = entries.filter { $0.status == "Critical" }.count
        let warningCount = entries.filter { $0.status == "Low" || $0.status == "High" }.count
        let normalCount = entries.filter { $0.status == "Normal" }.count
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                StatCard(title: "Total", value: "\(entries.count)", color: Color.blue)
                StatCard(title: "Normal", value: "\(normalCount)", color: Color.green)
                StatCard(title: "Warnings", value: "\(warningCount)", color: Color.orange)
                StatCard(title: "Critical", value: "\(criticalCount)", color: Color.red)
            }
        }
    }
    
    private var auditEntries: some View {
        let entries = dataManager.getAuditEntries(for: audit)
        let groupedEntries = Dictionary(grouping: entries) { $0.category ?? "Unknown" }
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Parameters")
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(Array(groupedEntries.keys.sorted()), id: \.self) { category in
                if let categoryEntries = groupedEntries[category] {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ForEach(categoryEntries, id: \.id) { entry in
                            AuditEntryRow(entry: entry)
                        }
                    }
                    .padding()
                    .background(Color.systemGray6)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func auditNotes(_ notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(notes)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.systemGray6)
                .cornerRadius(8)
        }
    }
}

struct AuditEntryRow: View {
    let entry: AuditEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.parameter ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let unit = entry.unit {
                    Text("\(String(format: "%.1f", entry.value)) \(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let status = entry.status {
                StatusIndicatorView(parameter: entry.parameter ?? "", value: entry.value)
            }
        }
        .padding(.vertical, 4)
    }
}
