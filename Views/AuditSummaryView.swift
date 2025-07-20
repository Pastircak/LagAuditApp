import SwiftUI

struct AuditSummaryView: View {
    let auditData: AuditData
    let dataManager: AuditDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var isSaving = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Audit Complete!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Review your audit data before saving")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Farm and Technician Info
                    VStack(spacing: 16) {
                        Text("Audit Information")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            InfoRow(label: "Farm", value: auditData.farm?.name ?? "Unknown")
                            InfoRow(label: "Technician", value: auditData.technician)
                            InfoRow(label: "Date", value: DateFormatter.auditDate.string(from: auditData.date))
                        }
                        .padding()
                        .background(Color.systemGray6)
                        .cornerRadius(12)
                    }
                    
                    // Statistics
                    VStack(spacing: 16) {
                        Text("Audit Results")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(title: "Total Parameters", value: "\(auditData.entries.count)", color: Color.blue)
                            StatCard(title: "Normal", value: "\(normalCount)", color: Color.green)
                            StatCard(title: "Warnings", value: "\(warningCount)", color: Color.orange)
                            StatCard(title: "Critical", value: "\(criticalCount)", color: Color.red)
                        }
                    }
                    
                    // Issues Summary
                    if !issues.isEmpty {
                        VStack(spacing: 16) {
                            Text("Issues Found")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach(issues, id: \.parameter) { issue in
                                    IssueRow(issue: issue)
                                }
                            }
                        }
                    }
                    
                    // Recommendations
                    if !recommendations.isEmpty {
                        VStack(spacing: 16) {
                            Text("Recommendations")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 8) {
                                ForEach(recommendations, id: \.self) { recommendation in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                        
                                        Text(recommendation)
                                            .font(.subheadline)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Audit Summary")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Audit") {
                        saveAudit()
                    }
                    .disabled(isSaving)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var normalCount: Int {
        auditData.entries.filter { $0.status == .normal }.count
    }
    
    private var warningCount: Int {
        auditData.entries.filter { $0.status == .warning }.count
    }
    
    private var criticalCount: Int {
        auditData.entries.filter { $0.status == .critical }.count
    }
    
    private var issues: [AuditIssue] {
        auditData.entries.compactMap { entry in
            guard entry.status != .normal else { return nil }
            return AuditIssue(
                parameter: entry.parameter,
                value: entry.value,
                status: convertToParameterStatus(entry.status),
                recommendation: entry.recommendation
            )
        }
    }
    
    private func convertToParameterStatus(_ auditStatus: AuditStatus) -> AuditGuidelines.ParameterStatus {
        switch auditStatus {
        case .normal:
            return .normal
        case .warning:
            return .high
        case .critical:
            return .critical
        }
    }
    
    private var recommendations: [String] {
        let allRecommendations = auditData.entries.compactMap { $0.recommendation }
        return Array(Set(allRecommendations)).sorted()
    }
    
    private func saveAudit() {
        isSaving = true
        
        Task {
            do {
                // Create the audit
                let audit = try dataManager.createAudit(
                    farmId: auditData.farm?.id?.uuidString ?? "",
                    farmName: auditData.farm?.name ?? "Unknown Farm",
                    technician: auditData.technician,
                    notes: ""
                )
                
                // Add audit entries
                for entry in auditData.entries {
                    if let value = Double(entry.value) {
                        try dataManager.addAuditEntry(
                            to: audit,
                            parameter: entry.parameter,
                            value: value,
                            unit: "units", // This should come from the parameter definition
                            category: "general" // This should come from the parameter definition
                        )
                    }
                }
                
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

struct AuditIssue {
    let parameter: String
    let value: String
    let status: AuditGuidelines.ParameterStatus
    let recommendation: String?
}

struct IssueRow: View {
    let issue: AuditIssue
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(issue.parameter)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Value: \(issue.value)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let recommendation = issue.recommendation {
                    Text(recommendation)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(statusColor.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var statusIcon: String {
        switch issue.status {
        case .low, .high:
            return "exclamationmark.triangle.fill"
        case .critical:
            return "xmark.circle.fill"
        case .normal:
            return "checkmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch issue.status {
        case .low, .high:
            return .orange
        case .critical:
            return .red
        case .normal:
            return .green
        }
    }
}

#Preview {
    AuditSummaryView(
        auditData: AuditData(
            farm: nil,
            technician: "John Doe",
            date: Date(),
            entries: []
        ),
        dataManager: AuditDataManager(context: PersistenceController.preview.container.viewContext)
    )
} 