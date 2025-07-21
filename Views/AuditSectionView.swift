import SwiftUI

struct AuditSectionView: View {
    let sectionName: String
    var body: some View {
        VStack {
            HStack {
                Image(systemName: iconName)
                    .font(.largeTitle)
                Text(sectionName.capitalized)
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(16)
            Spacer()
            Text("Inputs for \(sectionName.capitalized) go here.")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
    var iconName: String {
        switch sectionName.lowercased() {
        case "overview": return "list.bullet.rectangle"
        case "detachers": return "arrow.left.arrow.right"
        case "pulsators": return "waveform.path.ecg"
        case "vacuum": return "gauge"
        case "diagnostics": return "wrench.and.screwdriver"
        case "notes": return "note.text"
        default: return "questionmark"
        }
    }
} 