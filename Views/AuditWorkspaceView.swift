import SwiftUI

struct AuditWorkspaceView: View {
    @State private var selectedSection: AuditSection = .overview
    @State private var showSectionMap = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Farm: Example Farm").font(.headline)
                    Text("Date: \(Date(), formatter: dateFormatter)").font(.subheadline)
                    Text("Tech: J. Doe").font(.subheadline)
                }
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            
            // TabPicker
            Picker("Section", selection: $selectedSection) {
                ForEach(AuditSection.allCases) { section in
                    Text(section.title).tag(section)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.horizontal, .bottom])
            
            // Section content
            ZStack {
                switch selectedSection {
                case .farmInfo: FarmInfoView()
                case .milkingTime: MilkingTimeView()
                case .detachers: DetachersView()
                case .pulsators: PulsatorsView()
                case .diagnostics: DiagnosticsView()
                case .recommendations: RecommendationsView()
                case .overview: OverviewView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Toolbar
            HStack {
                Button(action: { showSectionMap = true }) {
                    Image(systemName: "square.grid.2x2")
                    Text("Section Map")
                }
                Spacer()
                Button("Previous") {
                    moveSection(-1)
                }
                .disabled(selectedSection == AuditSection.allCases.first)
                Button("Next") {
                    moveSection(1)
                }
                .disabled(selectedSection == AuditSection.allCases.last)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .sheet(isPresented: $showSectionMap) {
            SectionMapView(selectedSection: $selectedSection)
        }
    }
    
    private func moveSection(_ offset: Int) {
        guard let idx = AuditSection.allCases.firstIndex(of: selectedSection) else { return }
        let newIdx = idx + offset
        if newIdx >= 0 && newIdx < AuditSection.allCases.count {
            selectedSection = AuditSection.allCases[newIdx]
        }
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    return df
}() 