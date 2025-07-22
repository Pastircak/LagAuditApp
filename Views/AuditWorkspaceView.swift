import SwiftUI

struct AuditWorkspaceView: View {
    @State private var selectedSection: AuditSection = .overview
    @State private var showSectionMap = false
    @ObservedObject var auditManager: AuditDataManager
    @State private var showingSaveDraftAlert = false
    @State private var showingDraftSavedAlert = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Farm: \(auditManager.currentFarmInfo?.dairyName ?? "New Audit")").font(.headline)
                    Text("Date: \(Date(), formatter: dateFormatter)").font(.subheadline)
                    Text("Tech: \(auditManager.currentFarmInfo?.preparedBy ?? "Not specified")").font(.subheadline)
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
                case .farmInfo: FarmInfoView(auditViewModel: createAuditViewModel())
                case .milkingTime: MilkingTimeView(auditViewModel: createAuditViewModel())
                case .detachers: DetachersView(auditViewModel: createAuditViewModel())
                case .pulsators: PulsatorsView(auditViewModel: createAuditViewModel())
                case .diagnostics: DiagnosticsView(auditViewModel: createAuditViewModel())
                case .recommendations: RecommendationsView(auditViewModel: createAuditViewModel())
                case .overview:
                    OverviewView(auditViewModel: createAuditViewModel(), selectedSection: $selectedSection)
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
                
                Button(action: { showingSaveDraftAlert = true }) {
                    Image(systemName: "doc.text")
                    Text("Save Draft")
                }
                .disabled(!canSaveDraft)
                
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
        .alert("Save Draft", isPresented: $showingSaveDraftAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                saveDraft()
            }
        } message: {
            Text("This will save your current progress as a draft that you can resume later.")
        }
        .alert("Draft Saved", isPresented: $showingDraftSavedAlert) {
            Button("OK") { }
        } message: {
            Text("Your draft has been saved successfully. You can find it in the Drafts section.")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Start a new audit session if one isn't already in progress
            if auditManager.currentFarmInfo == nil {
                auditManager.startNewAuditSession()
            }
        }
    }
    
    private var canSaveDraft: Bool {
        // Can save draft if we have at least some farm info
        guard let farmInfo = auditManager.currentFarmInfo else { return false }
        return !farmInfo.dairyName.isEmpty || !farmInfo.preparedBy.isEmpty
    }
    
    private func saveDraft() {
        guard let farmInfo = auditManager.currentFarmInfo else {
            errorMessage = "No farm information available to save"
            showingError = true
            return
        }
        
        let farmId = UUID().uuidString // Generate a temporary ID for draft
        let farmName = farmInfo.dairyName.isEmpty ? "Unnamed Farm" : farmInfo.dairyName
        let technician = farmInfo.preparedBy.isEmpty ? "Unknown Technician" : farmInfo.preparedBy
        
        if let _ = auditManager.saveDraft(
            farmId: farmId,
            farmName: farmName,
            technician: technician,
            notes: "Draft saved on \(dateFormatter.string(from: Date()))"
        ) {
            showingDraftSavedAlert = true
        } else {
            errorMessage = "Failed to save draft"
            showingError = true
        }
    }
    
    private func createAuditViewModel() -> AuditViewModel {
        // Create a new audit ID for this session
        let auditID = UUID()
        return AuditViewModel(auditID: auditID)
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