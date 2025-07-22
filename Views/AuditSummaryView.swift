import SwiftUI
import UIKit

struct AuditSummaryView: View {
    let auditData: AuditData
    let dataManager: AuditDataManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isSaving = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingShareSheet = false
    @State private var pdfURL: URL?
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
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
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: exportPDF) {
                            HStack {
                                Image(systemName: "doc.richtext")
                                Text("Export PDF")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: saveAudit) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Save Audit")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isSaving ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isSaving)
                        
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Back")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Audit Summary")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = pdfURL {
                    ShareSheet(activityItems: [url])
                } else {
                    Text("No PDF available to share")
                        .padding()
                }
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
                status: entry.status,
                recommendation: entry.recommendation
            )
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
                        _ = try dataManager.addAuditEntry(
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
    
    private func exportPDF() {
        print("Starting PDF export...")
        
        // Create a temporary audit object for PDF generation
        let tempAudit = Audit(context: viewContext)
        tempAudit.id = UUID()
        tempAudit.farmId = auditData.farm?.id?.uuidString
        tempAudit.farmName = auditData.farm?.name
        tempAudit.technician = auditData.technician
        tempAudit.date = auditData.date
        tempAudit.notes = ""
        tempAudit.createdAt = Date()
        tempAudit.updatedAt = Date()
        
        // Add audit entries
        for entry in auditData.entries {
            let auditEntry = AuditEntry(context: viewContext)
            auditEntry.id = UUID()
            auditEntry.parameter = entry.parameter
            auditEntry.value = Double(entry.value) ?? 0.0
            auditEntry.unit = "units"
            auditEntry.status = entry.status.rawValue
            auditEntry.category = "general"
            auditEntry.createdAt = Date()
            auditEntry.audit = tempAudit
        }
        
        print("Generated \(auditData.entries.count) audit entries")
        
        if let url = generatePDFReport(for: tempAudit) {
            print("PDF generated successfully at: \(url)")
            pdfURL = url
            showingShareSheet = true
        } else {
            print("Failed to generate PDF report")
            errorMessage = "Failed to generate PDF report"
            showingError = true
        }
        
        // Clean up temporary objects
        viewContext.delete(tempAudit)
    }
    
    private func generatePDFReport(for audit: Audit) -> URL? {
        print("Starting PDF generation for audit: \(audit.id?.uuidString ?? "unknown")")
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("AuditReport_\(audit.id?.uuidString ?? "unknown").pdf")
        print("PDF will be saved to: \(tempURL)")
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792)) // 8.5" x 11"
        
        do {
            try renderer.writePDF(to: tempURL) { context in
                print("PDF renderer context created")
                context.beginPage()
                let pageRect = context.pdfContextBounds
                var yPosition: CGFloat = 20
                
                // Header
                let title = "LAG AUDIT REPORT"
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .foregroundColor: UIColor.black
                ]
                
                let titleSize = title.size(withAttributes: titleAttributes)
                let titleX = (pageRect.width - titleSize.width) / 2
                title.draw(at: CGPoint(x: titleX, y: yPosition), withAttributes: titleAttributes)
                yPosition += 40
                
                // Audit details
                let detailsAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.darkGray
                ]
                
                let farmName = audit.farmName ?? "Unknown Farm"
                let technician = audit.technician ?? "Unknown Technician"
                let dateString = audit.date?.formatted(date: .long, time: .omitted) ?? "Unknown Date"
                
                let details = [
                    "Farm: \(farmName)",
                    "Technician: \(technician)",
                    "Date: \(dateString)"
                ]
                
                for detail in details {
                    detail.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: detailsAttributes)
                    yPosition += 20
                }
                
                yPosition += 20
                
                // Audit Results
                let sectionTitle = "AUDIT RESULTS"
                let sectionAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 16),
                    .foregroundColor: UIColor.black
                ]
                
                sectionTitle.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: sectionAttributes)
                yPosition += 25
                
                // Draw a line under the section title
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: 50, y: yPosition))
                linePath.addLine(to: CGPoint(x: pageRect.width - 50, y: yPosition))
                UIColor.lightGray.setStroke()
                linePath.lineWidth = 1
                linePath.stroke()
                yPosition += 20
                
                // Table headers
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 12),
                    .foregroundColor: UIColor.black
                ]
                
                let headers = ["Parameter", "Value", "Unit", "Status"]
                let columnWidths: [CGFloat] = [200, 100, 80, 100]
                var xPosition: CGFloat = 60
                
                for (index, header) in headers.enumerated() {
                    header.draw(at: CGPoint(x: xPosition, y: yPosition), withAttributes: headerAttributes)
                    xPosition += columnWidths[index]
                }
                
                yPosition += 20
                
                // Draw header line
                let headerLinePath = UIBezierPath()
                headerLinePath.move(to: CGPoint(x: 60, y: yPosition))
                headerLinePath.addLine(to: CGPoint(x: pageRect.width - 60, y: yPosition))
                UIColor.black.setStroke()
                headerLinePath.lineWidth = 1
                headerLinePath.stroke()
                yPosition += 15
                
                // Audit entries
                let entryAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11),
                    .foregroundColor: UIColor.black
                ]
                
                if let entries = audit.entries?.allObjects as? [AuditEntry] {
                    print("Processing \(entries.count) audit entries")
                    for entry in entries {
                        xPosition = 60
                        
                        // Parameter name
                        let parameter = entry.parameter ?? "Unknown"
                        parameter.draw(at: CGPoint(x: xPosition, y: yPosition), withAttributes: entryAttributes)
                        xPosition += columnWidths[0]
                        
                        // Value
                        let value = String(format: "%.2f", entry.value)
                        value.draw(at: CGPoint(x: xPosition, y: yPosition), withAttributes: entryAttributes)
                        xPosition += columnWidths[1]
                        
                        // Unit
                        let unit = entry.unit ?? ""
                        unit.draw(at: CGPoint(x: xPosition, y: yPosition), withAttributes: entryAttributes)
                        xPosition += columnWidths[2]
                        
                        // Status
                        let status = entry.status ?? "Unknown"
                        let statusColor = statusColor(for: status)
                        let statusAttributes: [NSAttributedString.Key: Any] = [
                            .font: UIFont.systemFont(ofSize: 11),
                            .foregroundColor: statusColor
                        ]
                        status.draw(at: CGPoint(x: xPosition, y: yPosition), withAttributes: statusAttributes)
                        
                        yPosition += 18
                    }
                } else {
                    print("No audit entries found")
                    // Add a placeholder row
                    let placeholderText = "No audit data available"
                    placeholderText.draw(at: CGPoint(x: 60, y: yPosition), withAttributes: entryAttributes)
                }
                
                // Footer
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                
                let footerText = "Generated by Lag Audit App on \(Date().formatted(date: .long, time: .shortened))"
                let footerSize = footerText.size(withAttributes: footerAttributes)
                let footerX = (pageRect.width - footerSize.width) / 2
                let footerY = pageRect.height - 30
                
                footerText.draw(at: CGPoint(x: footerX, y: footerY), withAttributes: footerAttributes)
                
                print("PDF content drawn successfully")
            }
            print("PDF file created successfully")
            return tempURL
        } catch {
            print("Failed to create PDF: \(error)")
            return nil
        }
    }
    
    private func statusColor(for status: String) -> UIColor {
        switch status.lowercased() {
        case "normal", "good":
            return UIColor.systemGreen
        case "warning", "high", "low":
            return UIColor.systemOrange
        case "critical", "bad":
            return UIColor.systemRed
        default:
            return UIColor.black
        }
    }
}

struct AuditIssue {
    let parameter: String
    let value: String
    let status: ParameterStatus
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
        case .warning:
            return "exclamationmark.triangle.fill"
        case .critical:
            return "xmark.circle.fill"
        case .normal:
            return "checkmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch issue.status {
        case .warning:
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