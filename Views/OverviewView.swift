import SwiftUI
import UIKit

struct OverviewView: View {
    @ObservedObject var auditViewModel: AuditViewModel
    @Binding var selectedSection: AuditSection
    let sections: [AuditSection] = AuditSection.allCases
    @State private var showShareSheet = false
    @State private var pdfURL: URL? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Audit Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: exportPDF) {
                    Label("Export PDF", systemImage: "doc.richtext")
                }
            }
            List(sections, id: \.self) { section in
                OverviewSectionRow(
                    section: section,
                    progress: auditViewModel.progress(for: section),
                    missing: countMissingFields(for: section),
                    onTap: { selectedSection = section }
                )
            }
        }
        .padding()
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private func countMissingFields(for section: AuditSection) -> Int {
        switch section {
        case .farmInfo:
            guard let farmInfo = auditViewModel.farmInfo else { return 5 }
            let requiredFields = [
                farmInfo.dairyName,
                farmInfo.preparedBy,
                farmInfo.parlorConfig.rawValue,
                farmInfo.linerType.rawValue,
                farmInfo.systemType.rawValue
            ]
            return requiredFields.filter { $0.isEmpty }.count
        case .milkingTime:
            guard !auditViewModel.milkingTimeRows.isEmpty else { return 4 }
            var missing = 0
            for row in auditViewModel.milkingTimeRows {
                if row.avgVac == nil { missing += 1 }
                if row.maxVac == nil { missing += 1 }
                if row.minVac == nil { missing += 1 }
                if row.flowRate == nil { missing += 1 }
            }
            return missing
        case .detachers:
            guard let settings = auditViewModel.detacherSettings else { return 4 }
            let requiredFields = [
                settings.clusterRemovalDelay,
                settings.blinkTimeDelay,
                settings.detachFlowSetting,
                settings.letDownDelay
            ]
            return requiredFields.filter { $0 == nil }.count
        case .pulsators:
            guard !auditViewModel.pulsatorRows.isEmpty else { return 3 }
            var missing = 0
            for row in auditViewModel.pulsatorRows {
                if row.ratioFront == nil { missing += 1 }
                if row.ratioRear == nil { missing += 1 }
                if row.rate == nil { missing += 1 }
            }
            return missing
        case .diagnostics:
            guard let diagnostics = auditViewModel.diagnostics else { return 17 }
            let mirror = Mirror(reflecting: diagnostics)
            return mirror.children.filter { 
                if let value = $0.value as? Double {
                    return value == 0.0
                }
                return $0.value == nil
            }.count
        case .recommendations:
            return auditViewModel.recommendations.isEmpty ? 1 : 0
        case .overview:
            return 0
        }
    }
    
    private func exportPDF() {
        // Simple PDF with section names and progress (placeholder)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("AuditOverview.pdf")
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 300, height: 44 * sections.count + 60))
        do {
            try renderer.writePDF(to: tempURL) { ctx in
                ctx.beginPage()
                let title = "Audit Overview"
                title.draw(at: CGPoint(x: 20, y: 20), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 18)])
                for (i, section) in sections.enumerated() {
                    let y = 60 + i * 44
                    let progress = auditViewModel.progress(for: section)
                    let missing = countMissingFields(for: section)
                    let text = "\(section.title): Progress \(Int(progress * 100))% | Missing \(missing)"
                    text.draw(at: CGPoint(x: 20, y: CGFloat(y)), withAttributes: [.font: UIFont.systemFont(ofSize: 14)])
                }
            }
            pdfURL = tempURL
            showShareSheet = true
        } catch {
            print("Failed to create PDF: \(error)")
        }
    }
}

struct OverviewSectionRow: View {
    let section: AuditSection
    let progress: Double
    let missing: Int
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: icon(for: section))
                    .foregroundColor(.accentColor)
                Text(section.title)
                    .font(.headline)
                Spacer()
                StatusRing(progress: progress)
                Text("\(missing) missing")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func icon(for section: AuditSection) -> String {
        switch section {
        case .farmInfo: return "building.2"
        case .milkingTime: return "tuningfork"
        case .detachers: return "arrow.left.arrow.right"
        case .pulsators: return "waveform.path.ecg"
        case .diagnostics: return "gauge"
        case .recommendations: return "checklist"
        case .overview: return "list.bullet.rectangle"
        }
    }
}

struct StatusRing: View {
    let progress: Double // 0.0 to 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(progressColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
        .frame(width: 24, height: 24)
    }
    
    private var progressColor: Color {
        if progress >= 0.8 { return .green }
        else if progress >= 0.5 { return .orange }
        else { return .red }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 