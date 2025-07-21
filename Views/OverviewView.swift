import SwiftUI

struct OverviewView: View {
    let sections: [AuditSection] = AuditSection.allCases
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Audit Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { /* PDF export placeholder */ }) {
                    Label("Export PDF", systemImage: "doc.richtext")
                }
            }
            List(sections, id: \ .self) { section in
                OverviewSectionRow(section: section, onTap: { /* Jump to section callback placeholder */ })
            }
        }
        .padding()
    }
}

struct OverviewSectionRow: View {
    let section: AuditSection
    var onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: icon(for: section))
                    .foregroundColor(.accentColor)
                Text(section.title)
                    .font(.headline)
                Spacer()
                StatusRing(progress: 0.5) // Placeholder for progress
                Text("0 missing") // Placeholder for missing count
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
                .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                .frame(width: 28, height: 28)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(Color.green, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 28, height: 28)
        }
    }
} 