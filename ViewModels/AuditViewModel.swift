import SwiftUI
import CoreData
import Combine

@MainActor final class AuditViewModel: ObservableObject {
    @Published var audit: Audit?
    @Published var showMap = false
    @Published var currentSection: AuditSection = .farmInfo
    
    // MARK: - Audit Data Properties (Single Source of Truth)
    @Published var farmInfo: FarmInfo?
    @Published var milkingTimeRows: [MilkingTimeRow] = []
    @Published var detacherSettings: DetacherSettings?
    @Published var pulsatorRows: [PulsatorRow] = []
    @Published var pulsationAverages: PulsationAverage?
    @Published var voltageChecks: VoltageChecks?
    @Published var diagnostics: Diagnostics?
    @Published var recommendations: [Recommendation] = []
    
    // MARK: - Autosave Properties
    @Published var isSaving = false
    @Published var lastSaved: Date?
    private var autosaveTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private let auditID: UUID
    private let context: NSManagedObjectContext
    
    init(auditID: UUID, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.auditID = auditID
        self.context = context
        setupAutosave()
        loadAudit()
    }
    
    deinit {
        autosaveTimer?.invalidate()
        // Removed flushIfNeeded() to avoid main actor isolation error
    }
    
    // MARK: - Autosave Setup
    private func setupAutosave() {
        // Combine all published properties for autosave
        Publishers.CombineLatest4(
            $farmInfo,
            $milkingTimeRows,
            $detacherSettings,
            $pulsatorRows
        )
        .combineLatest(
            Publishers.CombineLatest4(
                $pulsationAverages,
                $voltageChecks,
                $diagnostics,
                $recommendations
            )
        )
        .debounce(for: .seconds(2), scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.autosave()
        }
        .store(in: &cancellables)
    }
    
    private func autosave() {
        guard let audit = audit else { return }
        
        isSaving = true
        
        // Update audit with current data
        updateAuditWithCurrentData(audit)
        audit.updatedAt = Date()
        
        do {
            try context.save()
            lastSaved = Date()
            print("Autosave completed at \(Date())")
        } catch {
            print("Autosave failed: \(error)")
        }
        
        isSaving = false
    }
    
    private func updateAuditWithCurrentData(_ audit: Audit) {
        // Update basic audit properties
        if let farmInfo = farmInfo {
            audit.farmName = farmInfo.dairyName
            audit.technician = farmInfo.preparedBy
            audit.farmInfoData = try? JSONEncoder().encode(farmInfo)
        }
        
        // Update other sections
        audit.milkingTimeData = try? JSONEncoder().encode(milkingTimeRows)
        audit.detacherSettingsData = try? JSONEncoder().encode(detacherSettings)
        audit.pulsatorData = try? JSONEncoder().encode(pulsatorRows)
        audit.pulsationAveragesData = try? JSONEncoder().encode(pulsationAverages)
        audit.voltageChecksData = try? JSONEncoder().encode(voltageChecks)
        audit.diagnosticsData = try? JSONEncoder().encode(diagnostics)
        audit.recommendationsData = try? JSONEncoder().encode(recommendations)
    }
    
    // MARK: - Audit Loading
    private func loadAudit() {
        let request: NSFetchRequest<Audit> = Audit.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", auditID as CVarArg)
        
        do {
            let audits = try context.fetch(request)
            if let audit = audits.first {
                self.audit = audit
                loadDataFromAudit(audit)
            } else {
                // Create new audit if not found
                createNewAudit()
            }
        } catch {
            print("Error loading audit: \(error)")
            createNewAudit()
        }
    }
    
    private func loadDataFromAudit(_ audit: Audit) {
        // Load farm info
        if let farmInfoData = audit.farmInfoData {
            farmInfo = try? JSONDecoder().decode(FarmInfo.self, from: farmInfoData)
        }
        
        // Load other sections
        if let milkingTimeData = audit.milkingTimeData {
            milkingTimeRows = (try? JSONDecoder().decode([MilkingTimeRow].self, from: milkingTimeData)) ?? []
        }
        
        if let detacherSettingsData = audit.detacherSettingsData {
            detacherSettings = try? JSONDecoder().decode(DetacherSettings.self, from: detacherSettingsData)
        }
        
        if let pulsatorData = audit.pulsatorData {
            pulsatorRows = (try? JSONDecoder().decode([PulsatorRow].self, from: pulsatorData)) ?? []
        }
        
        if let pulsationAveragesData = audit.pulsationAveragesData {
            pulsationAverages = try? JSONDecoder().decode(PulsationAverage.self, from: pulsationAveragesData)
        }
        
        if let voltageChecksData = audit.voltageChecksData {
            voltageChecks = try? JSONDecoder().decode(VoltageChecks.self, from: voltageChecksData)
        }
        
        if let diagnosticsData = audit.diagnosticsData {
            diagnostics = try? JSONDecoder().decode(Diagnostics.self, from: diagnosticsData)
        }
        
        if let recommendationsData = audit.recommendationsData {
            recommendations = (try? JSONDecoder().decode([Recommendation].self, from: recommendationsData)) ?? []
        }
    }
    
    private func createNewAudit() {
        let newAudit = Audit(context: context)
        newAudit.id = auditID
        newAudit.createdAt = Date()
        newAudit.updatedAt = Date()
        newAudit.status = AuditStatus.draft.rawValue
        self.audit = newAudit
        
        do {
            try context.save()
        } catch {
            print("Error creating new audit: \(error)")
        }
    }
    
    // MARK: - Public Methods
    func saveAsDraft() {
        guard let audit = audit else { return }
        audit.status = AuditStatus.draft.rawValue
        updateAuditWithCurrentData(audit)
        audit.updatedAt = Date()
        
        do {
            try context.save()
            print("Draft saved successfully")
        } catch {
            print("Error saving draft: \(error)")
        }
    }
    
    func progress(for section: AuditSection) -> Double {
        switch section {
        case .farmInfo:
            return calculateFarmInfoProgress()
        case .milkingTime:
            return calculateMilkingTimeProgress()
        case .detachers:
            return calculateDetachersProgress()
        case .pulsators:
            return calculatePulsatorsProgress()
        case .diagnostics:
            return calculateDiagnosticsProgress()
        case .recommendations:
            return calculateRecommendationsProgress()
        case .overview:
            return 1.0
        }
    }
    
    func hasFlags(in section: AuditSection) -> Bool {
        // TODO: Implement flag checking based on validation rules
        return false
    }
    
    func flushIfNeeded() {
        // Auto-save when view disappears
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error auto-saving: \(error)")
            }
        }
    }
    
    // MARK: - Progress Calculation Methods
    private func calculateFarmInfoProgress() -> Double {
        guard let farmInfo = farmInfo else { return 0.0 }
        
        let requiredFields = [
            farmInfo.dairyName,
            farmInfo.preparedBy,
            farmInfo.parlorConfig.rawValue,
            farmInfo.linerType.rawValue,
            farmInfo.systemType.rawValue
        ]
        
        let completedFields = requiredFields.filter { !$0.isEmpty }.count
        return Double(completedFields) / Double(requiredFields.count)
    }
    
    private func calculateMilkingTimeProgress() -> Double {
        guard !milkingTimeRows.isEmpty else { return 0.0 }
        
        let totalFields = milkingTimeRows.count * 4 // avgVac, maxVac, minVac, flowRate
        var completedFields = 0
        
        for row in milkingTimeRows {
            if row.avgVac != nil { completedFields += 1 }
            if row.maxVac != nil { completedFields += 1 }
            if row.minVac != nil { completedFields += 1 }
            if row.flowRate != nil { completedFields += 1 }
        }
        
        return Double(completedFields) / Double(totalFields)
    }
    
    private func calculateDetachersProgress() -> Double {
        guard let settings = detacherSettings else { return 0.0 }
        
        let requiredFields = [
            settings.clusterRemovalDelay,
            settings.blinkTimeDelay,
            settings.detachFlowSetting,
            settings.letDownDelay
        ]
        
        let completedFields = requiredFields.filter { $0 != nil }.count
        return Double(completedFields) / Double(requiredFields.count)
    }
    
    private func calculatePulsatorsProgress() -> Double {
        guard !pulsatorRows.isEmpty else { return 0.0 }
        
        let totalFields = pulsatorRows.count * 3 // ratioFront, ratioRear, rate
        var completedFields = 0
        
        for row in pulsatorRows {
            if row.ratioFront != nil { completedFields += 1 }
            if row.ratioRear != nil { completedFields += 1 }
            if row.rate != nil { completedFields += 1 }
        }
        
        return Double(completedFields) / Double(totalFields)
    }
    
    private func calculateDiagnosticsProgress() -> Double {
        guard let diagnostics = diagnostics else { return 0.0 }
        
        // Count non-nil diagnostic values
        let mirror = Mirror(reflecting: diagnostics)
        let totalFields = mirror.children.count
        let completedFields = mirror.children.filter { 
            if let value = $0.value as? Double {
                return value != 0.0
            }
            return $0.value != nil
        }.count
        
        return Double(completedFields) / Double(totalFields)
    }
    
    private func calculateRecommendationsProgress() -> Double {
        return recommendations.isEmpty ? 0.0 : 1.0
    }
} 