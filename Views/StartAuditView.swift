import SwiftUI

struct StartAuditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var dataManager: AuditDataManager
    @State private var currentStep = 0
    @State private var showingFarmSelection = false
    @State private var selectedFarm: Farm?
    @State private var technicianName = ""
    @State private var auditNotes = ""
    @State private var currentAudit: Audit?
    @State private var showingAuditSummary = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Form data for each section
    @State private var vacuumData: [String: Double] = [:]
    @State private var pulsationData: [String: Double] = [:]
    @State private var flowData: [String: Double] = [:]
    @State private var detacherData: [String: Double] = [:]
    @State private var generalData: [String: Double] = [:]
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _dataManager = StateObject(wrappedValue: AuditDataManager(context: context))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: Double(currentStep), total: Double(AuditForm.sections.count + 2))
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()
                
                // Step content
                ScrollView {
                    VStack(spacing: 20) {
                        switch currentStep {
                        case 0:
                            farmSelectionStep
                        case 1:
                            technicianStep
                        case 2...AuditForm.sections.count + 1:
                            let sectionIndex = currentStep - 2
                            if sectionIndex < AuditForm.sections.count {
                                auditSectionStep(AuditForm.sections[sectionIndex])
                            }
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            currentStep -= 1
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if currentStep < AuditForm.sections.count + 1 {
                        Button(currentStep == AuditForm.sections.count + 1 ? "Review" : "Next") {
                            if currentStep == AuditForm.sections.count + 1 {
                                showingAuditSummary = true
                            } else {
                                currentStep += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canProceed)
                    }
                }
                .padding()
            }
            .navigationTitle("New Audit")
            .sheet(isPresented: $showingFarmSelection) {
                FarmSelectionView(selectedFarm: $selectedFarm, dataManager: dataManager)
            }
            .sheet(isPresented: $showingAuditSummary) {
                AuditSummaryView(
                    auditData: createAuditData(),
                    dataManager: dataManager
                )
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return selectedFarm != nil
        case 1:
            return !technicianName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default:
            return true
        }
    }
    
    // MARK: - Step Views
    private var farmSelectionStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Farm")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Choose the farm where you're conducting the audit")
                .foregroundColor(.secondary)
            
            if let farm = selectedFarm {
                FarmCardView(farm: farm)
            } else {
                Button("Select Farm") {
                    showingFarmSelection = true
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    private var technicianStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Technician Information")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enter your name as the technician conducting this audit")
                .foregroundColor(.secondary)
            
            TextField("Technician Name", text: $technicianName)
                .textFieldStyle(.roundedBorder)
            
            Text("Notes (Optional)")
                .font(.headline)
            
            TextEditor(text: $auditNotes)
                .frame(minHeight: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private func auditSectionStep(_ section: AuditForm.Section) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(section.title)
                .font(.title2)
                .fontWeight(.bold)
            
            if let subtitle = section.subtitle {
                Text(subtitle)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(section.parameters, id: \.self) { parameter in
                    ParameterInputView(
                        parameter: parameter,
                        value: getValue(for: parameter),
                        onValueChanged: { newValue in
                            setValue(newValue, for: parameter)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getValue(for parameter: String) -> Double {
        if let definition = AuditGuidelines.getParameterDefinition(for: parameter) {
            switch definition.category {
            case .vacuum:
                return vacuumData[parameter] ?? 0
            case .pulsation:
                return pulsationData[parameter] ?? 0
            case .flow:
                return flowData[parameter] ?? 0
            case .detacher:
                return detacherData[parameter] ?? 0
            case .general:
                return generalData[parameter] ?? 0
            }
        }
        return 0
    }
    
    private func setValue(_ value: Double, for parameter: String) {
        if let definition = AuditGuidelines.getParameterDefinition(for: parameter) {
            switch definition.category {
            case .vacuum:
                vacuumData[parameter] = value
            case .pulsation:
                pulsationData[parameter] = value
            case .flow:
                flowData[parameter] = value
            case .detacher:
                detacherData[parameter] = value
            case .general:
                generalData[parameter] = value
            }
        }
    }
    
    private func getAllAuditData() -> [String: Double] {
        var allData: [String: Double] = [:]
        allData.merge(vacuumData) { _, new in new }
        allData.merge(pulsationData) { _, new in new }
        allData.merge(flowData) { _, new in new }
        allData.merge(detacherData) { _, new in new }
        allData.merge(generalData) { _, new in new }
        return allData
    }
    
    private func createAuditData() -> AuditData {
        let allData = getAllAuditData()
        let entries = allData.map { parameter, value in
            let status = AuditGuidelines.evaluateParameter(parameter, value: value)
            let auditStatus: ParameterStatus
            switch status {
            case .normal:
                auditStatus = .normal
            case .low, .high:
                auditStatus = .warning
            case .critical:
                auditStatus = .critical
            }
            
            let recommendations = AuditGuidelines.getRecommendations(for: parameter, value: value)
            let recommendation = recommendations.isEmpty ? nil : recommendations.joined(separator: "; ")
            
            return AuditEntryData(
                parameter: parameter,
                value: String(format: "%.1f", value),
                status: auditStatus,
                recommendation: recommendation
            )
        }
        
        return AuditData(
            farm: selectedFarm,
            technician: technicianName,
            date: Date(),
            entries: entries
        )
    }
}

// MARK: - Parameter Input View
struct ParameterInputView: View {
    let parameter: String
    let value: Double
    let onValueChanged: (Double) -> Void
    
    @State private var textValue = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(parameter)
                    .font(.headline)
                Spacer()
                StatusIndicatorView(parameter: parameter, value: value)
            }
            
            if let definition = AuditGuidelines.getParameterDefinition(for: parameter) {
                Text(definition.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("Value", text: $textValue)
                        .textFieldStyle(.roundedBorder)
                        .focused($isFocused)
                        .onChange(of: textValue) { _, newValue in
                            if let doubleValue = Double(newValue) {
                                onValueChanged(doubleValue)
                            }
                        }
                        .onAppear {
                            textValue = value > 0 ? String(format: "%.1f", value) : ""
                        }
                    
                    Text(definition.unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 40, alignment: .leading)
                }
                
                // Range indicator
                HStack {
                    Text("Range: \(String(format: "%.1f", definition.minValue)) - \(String(format: "%.1f", definition.maxValue))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let target = definition.targetValue {
                        Text("Target: \(String(format: "%.1f", target))")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                // Recommendations
                if value > 0 {
                    let recommendations = AuditGuidelines.getRecommendations(for: parameter, value: value)
                    if !recommendations.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Recommendations:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            ForEach(recommendations, id: \.self) { recommendation in
                                Text("• \(recommendation)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color.systemGray6)
        .cornerRadius(8)
    }
}

// MARK: - Status Indicator View
struct StatusIndicatorView: View {
    let parameter: String
    let value: Double
    
    var body: some View {
        let status = AuditGuidelines.evaluateParameter(parameter, value: value)
        
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .foregroundColor(Color(status.color))
            
            Text(status.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(status.color))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(status.color).opacity(0.1))
        .cornerRadius(4)
    }
}

// MARK: - Farm Card View
struct FarmCardView: View {
    let farm: Farm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(farm.name ?? "Unknown Farm")
                .font(.headline)
            
            if let location = farm.location {
                Text(location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let contact = farm.contactPerson {
                Text("Contact: \(contact)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.systemGray6)
        .cornerRadius(8)
    }
}
