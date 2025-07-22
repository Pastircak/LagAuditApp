import SwiftUI

struct AuditShellView: View {
    @StateObject private var auditViewModel: AuditViewModel
    @ObservedObject var dataManager: AuditDataManager
    @ObservedObject var router: AppRouter
    @Environment(\.horizontalSizeClass) private var hSize
    @Environment(\.dismiss) private var dismiss

    @State private var showingSectionMap = false
    @State private var showingExitAlert = false

    init(auditID: UUID, dataManager: AuditDataManager, router: AppRouter) {
        self._auditViewModel = StateObject(wrappedValue: AuditViewModel(auditID: auditID))
        self.dataManager = dataManager
        self.router = router
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            AuditHeaderView(auditViewModel: auditViewModel)
            
            // Section Map for iPad/Mac
            if hSize == .regular {
                SectionMapHorizontalView(currentSection: $auditViewModel.currentSection, auditViewModel: auditViewModel)
            }
            
            // Tab Picker
            SectionTabPicker(currentSection: $auditViewModel.currentSection)

            Divider()
            
            // Current Section View
            sectionView(for: auditViewModel.currentSection)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("◁") { 
                    if let prev = auditViewModel.currentSection.prev {
                        auditViewModel.currentSection = prev
                    }
                }
                .disabled(auditViewModel.currentSection.isFirst)
                
                Spacer()
                
                Button("Map") { 
                    showingSectionMap = true
                }
                
                Spacer()
                
                Button("▷") { 
                    if let next = auditViewModel.currentSection.next {
                        auditViewModel.currentSection = next
                    }
                }
                .disabled(auditViewModel.currentSection.isLast)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if auditViewModel.isSaving {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    
                    Button {
                        auditViewModel.saveAsDraft()
                    } label: { 
                        Image(systemName: "tray.and.arrow.down")
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    showingExitAlert = true
                }
            }
        }
        .sheet(isPresented: $showingSectionMap) {
            SectionMapSheetView(selectedSection: $auditViewModel.currentSection, auditViewModel: auditViewModel)
        }
        .alert("Leave Audit?", isPresented: $showingExitAlert) {
            Button("Save & Exit") {
                auditViewModel.saveAsDraft()
                router.popToRoot()
            }
            Button("Discard", role: .destructive) {
                router.popToRoot()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Do you want to save this as a draft or discard your changes?")
        }
        .onDisappear {
            auditViewModel.flushIfNeeded()
        }
    }
    
    @ViewBuilder
    private func sectionView(for section: AuditSection) -> some View {
        switch section {
        case .farmInfo:
            FarmInfoView(auditViewModel: auditViewModel)
        case .milkingTime:
            MilkingTimeView(auditViewModel: auditViewModel)
        case .detachers:
            DetachersView(auditViewModel: auditViewModel)
        case .pulsators:
            PulsatorsView(auditViewModel: auditViewModel)
        case .diagnostics:
            DiagnosticsView(auditViewModel: auditViewModel)
        case .recommendations:
            RecommendationsView(auditViewModel: auditViewModel)
        case .overview:
            OverviewView(auditViewModel: auditViewModel, selectedSection: $auditViewModel.currentSection)
        }
    }
}

// MARK: - Supporting Views

struct AuditHeaderView: View {
    @ObservedObject var auditViewModel: AuditViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(auditViewModel.farmInfo?.dairyName ?? "New Audit")
                    .font(.headline)
                Spacer()
                Text(auditViewModel.farmInfo?.preparedBy ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let date = auditViewModel.farmInfo?.date {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let lastSaved = auditViewModel.lastSaved {
                Text("Last saved: \(lastSaved, style: .relative)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

struct SectionMapHorizontalView: View {
    @Binding var currentSection: AuditSection
    @ObservedObject var auditViewModel: AuditViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AuditSection.allCases) { section in
                    Button {
                        currentSection = section
                    } label: {
                        VStack(spacing: 4) {
                            ProgressRingView(progress: auditViewModel.progress(for: section))
                                .frame(width: 32, height: 32)
                            Text(section.label)
                                .font(.caption)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(currentSection == section ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
}

struct SectionTabPicker: View {
    @Binding var currentSection: AuditSection
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(AuditSection.allCases) { section in
                    Button {
                        currentSection = section
                    } label: {
                        Text(section.label)
                            .font(.subheadline)
                            .fontWeight(currentSection == section ? .semibold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(currentSection == section ? Color.blue : Color.clear)
                            .foregroundColor(currentSection == section ? .white : .primary)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct ProgressRingView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
        }
    }
}

struct SectionMapSheetView: View {
    @Binding var selectedSection: AuditSection
    @ObservedObject var auditViewModel: AuditViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 120))]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(AuditSection.allCases) { section in
                        Button {
                            selectedSection = section
                            dismiss()
                        } label: {
                            VStack {
                                ProgressRingView(progress: auditViewModel.progress(for: section))
                                    .frame(width: 44, height: 44)
                                Text(section.label)
                                    .font(.headline)
                                if auditViewModel.hasFlags(in: section) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.yellow)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedSection == section ? Color.green.opacity(0.2) : .secondary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Section Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
} 