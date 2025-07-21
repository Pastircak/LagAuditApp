import SwiftUI

struct SectionMapView: View {
    @Binding var selectedSection: AuditSection
    // Dummy status for each section
    let sectionStatus: [AuditSection: SectionStatus] = [
        .overview: .done,
        .farmInfo: .pending,
        .milkingTime: .pending,
        .detachers: .pending,
        .pulsators: .flagged,
        .diagnostics: .pending,
        .recommendations: .done
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Section Map").font(.title2).padding(.bottom)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 24) {
                ForEach(AuditSection.allCases) { section in
                    Button(action: {
                        selectedSection = section
                    }) {
                        VStack {
                            Text(section.rawValue.capitalized)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                            StatusChip(status: sectionStatus[section] ?? .pending)
                        }
                        .padding()
                        .frame(minHeight: 80)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

enum SectionStatus { case done, pending, flagged }

struct StatusChip: View {
    let status: SectionStatus
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    var color: Color {
        switch status {
        case .done: return .green
        case .pending: return .gray
        case .flagged: return .yellow
        }
    }
    var label: String {
        switch status {
        case .done: return "Done"
        case .pending: return "Pending"
        case .flagged: return "Flagged"
        }
    }
} 