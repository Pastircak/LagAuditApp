import Foundation
import CoreData
import SwiftUI

@MainActor
class AuditDataManager: ObservableObject {
    private let context: NSManagedObjectContext
    
    @Published var farms: [Farm] = []
    @Published var audits: [Audit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Current Audit Session Data
    @Published var currentFarmInfo: FarmInfo?
    @Published var currentMilkingTimeRows: [MilkingTimeRow] = []
    @Published var currentDetacherSettings: DetacherSettings?
    @Published var currentPulsatorRows: [PulsatorRow] = []
    @Published var currentPulsationAverage: PulsationAverage?
    @Published var currentVoltageChecks: VoltageChecks?
    @Published var currentDiagnostics: Diagnostics?
    @Published var currentRecommendations: [Recommendation] = []
    
    // MARK: - Draft Management
    @Published var drafts: [Audit] = []
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadData()
    }
    
    // MARK: - Section Progress Tracking
    var sectionProgress: [AuditSection: Double] {
        var progress: [AuditSection: Double] = [:]
        
        // Farm Info Progress
        progress[.farmInfo] = calculateFarmInfoProgress()
        
        // Milking Time Progress
        progress[.milkingTime] = calculateMilkingTimeProgress()
        
        // Detachers Progress
        progress[.detachers] = calculateDetachersProgress()
        
        // Pulsators Progress
        progress[.pulsators] = calculatePulsatorsProgress()
        
        // Diagnostics Progress
        progress[.diagnostics] = calculateDiagnosticsProgress()
        
        // Recommendations Progress
        progress[.recommendations] = calculateRecommendationsProgress()
        
        // Overview is always complete
        progress[.overview] = 1.0
        
        return progress
    }
    
    var sectionMissing: [AuditSection: Int] {
        var missing: [AuditSection: Int] = [:]
        
        missing[.farmInfo] = countMissingFarmInfoFields()
        missing[.milkingTime] = countMissingMilkingTimeFields()
        missing[.detachers] = countMissingDetachersFields()
        missing[.pulsators] = countMissingPulsatorsFields()
        missing[.diagnostics] = countMissingDiagnosticsFields()
        missing[.recommendations] = countMissingRecommendationsFields()
        missing[.overview] = 0
        
        return missing
    }
    
    // MARK: - Progress Calculation Methods
    private func calculateFarmInfoProgress() -> Double {
        guard let farmInfo = currentFarmInfo else { return 0.0 }
        
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
        guard !currentMilkingTimeRows.isEmpty else { return 0.0 }
        
        let totalFields = currentMilkingTimeRows.count * 4 // avgVac, maxVac, minVac, flowRate
        var completedFields = 0
        
        for row in currentMilkingTimeRows {
            if row.avgVac != nil { completedFields += 1 }
            if row.maxVac != nil { completedFields += 1 }
            if row.minVac != nil { completedFields += 1 }
            if row.flowRate != nil { completedFields += 1 }
        }
        
        return Double(completedFields) / Double(totalFields)
    }
    
    private func calculateDetachersProgress() -> Double {
        guard let detachers = currentDetacherSettings else { return 0.0 }
        
        let requiredFields = [
            detachers.clusterRemovalDelay,
            detachers.blinkTimeDelay,
            detachers.detachFlowSetting,
            detachers.letDownDelay
        ]
        
        let completedFields = requiredFields.compactMap { $0 }.count
        return Double(completedFields) / Double(requiredFields.count)
    }
    
    private func calculatePulsatorsProgress() -> Double {
        guard !currentPulsatorRows.isEmpty else { return 0.0 }
        
        let totalFields = currentPulsatorRows.count * 3 // ratioFront, ratioRear, rate
        var completedFields = 0
        
        for row in currentPulsatorRows {
            if row.ratioFront != nil { completedFields += 1 }
            if row.ratioRear != nil { completedFields += 1 }
            if row.rate != nil { completedFields += 1 }
        }
        
        return Double(completedFields) / Double(totalFields)
    }
    
    private func calculateDiagnosticsProgress() -> Double {
        guard let diagnostics = currentDiagnostics else { return 0.0 }
        
        let requiredFields = [
            diagnostics.step1ReceiverVac,
            diagnostics.step2ReceiverVac,
            diagnostics.step3ReceiverVac,
            diagnostics.step4ReceiverVac,
            diagnostics.step5ReceiverVac,
            diagnostics.step6ReceiverVac,
            diagnostics.step7ReceiverVac
        ]
        
        let completedFields = requiredFields.compactMap { $0 }.count
        return Double(completedFields) / Double(requiredFields.count)
    }
    
    private func calculateRecommendationsProgress() -> Double {
        guard !currentRecommendations.isEmpty else { return 0.0 }
        
        let totalFields = currentRecommendations.count
        let completedFields = currentRecommendations.filter { !$0.text.isEmpty }.count
        
        return Double(completedFields) / Double(totalFields)
    }
    
    // MARK: - Missing Fields Count Methods
    private func countMissingFarmInfoFields() -> Int {
        guard let farmInfo = currentFarmInfo else { return 5 }
        
        var missing = 0
        if farmInfo.dairyName.isEmpty { missing += 1 }
        if farmInfo.preparedBy.isEmpty { missing += 1 }
        // Note: parlorConfig, linerType, systemType are non-optional enums, so they're always present
        
        return missing
    }
    
    private func countMissingMilkingTimeFields() -> Int {
        guard !currentMilkingTimeRows.isEmpty else { return 4 }
        
        var missing = 0
        for row in currentMilkingTimeRows {
            if row.avgVac == nil { missing += 1 }
            if row.maxVac == nil { missing += 1 }
            if row.minVac == nil { missing += 1 }
            if row.flowRate == nil { missing += 1 }
        }
        
        return missing
    }
    
    private func countMissingDetachersFields() -> Int {
        guard let detachers = currentDetacherSettings else { return 4 }
        
        var missing = 0
        if detachers.clusterRemovalDelay == nil { missing += 1 }
        if detachers.blinkTimeDelay == nil { missing += 1 }
        if detachers.detachFlowSetting == nil { missing += 1 }
        if detachers.letDownDelay == nil { missing += 1 }
        
        return missing
    }
    
    private func countMissingPulsatorsFields() -> Int {
        guard !currentPulsatorRows.isEmpty else { return 3 }
        
        var missing = 0
        for row in currentPulsatorRows {
            if row.ratioFront == nil { missing += 1 }
            if row.ratioRear == nil { missing += 1 }
            if row.rate == nil { missing += 1 }
        }
        
        return missing
    }
    
    private func countMissingDiagnosticsFields() -> Int {
        guard let diagnostics = currentDiagnostics else { return 7 }
        
        var missing = 0
        if diagnostics.step1ReceiverVac == nil { missing += 1 }
        if diagnostics.step2ReceiverVac == nil { missing += 1 }
        if diagnostics.step3ReceiverVac == nil { missing += 1 }
        if diagnostics.step4ReceiverVac == nil { missing += 1 }
        if diagnostics.step5ReceiverVac == nil { missing += 1 }
        if diagnostics.step6ReceiverVac == nil { missing += 1 }
        if diagnostics.step7ReceiverVac == nil { missing += 1 }
        
        return missing
    }
    
    private func countMissingRecommendationsFields() -> Int {
        guard !currentRecommendations.isEmpty else { return 1 }
        
        return currentRecommendations.filter { $0.text.isEmpty }.count
    }
    
    // MARK: - Session Management
    func startNewAuditSession() {
        currentFarmInfo = FarmInfo(
            dairyName: "", address: "", city: "", state: "", zip: "",
            date: Date(), preparedBy: "", contactName: "", phone: "", email: "",
            numberOfCows: 0, numberOfStalls: 0, milkingFrequency: 0,
            parlorConfig: .other, linerType: .classic, milkHoseID: .fiveEighths,
            milkProductionLbs: nil, scc: nil, systemType: .other,
            milkLineIDs: [], milkLineSlope: nil, vacuumPumpHP: nil, hasVFD: nil
        )
        currentMilkingTimeRows = (1...10).map { MilkingTimeRow(position: Int16($0)) }
        currentDetacherSettings = DetacherSettings(
            clusterRemovalDelay: nil, blinkTimeDelay: nil,
            detachFlowSetting: nil, letDownDelay: nil, notes: ""
        )
        currentPulsatorRows = (1...6).map { PulsatorRow(number: Int16($0)) }
        currentPulsationAverage = PulsationAverage()
        currentVoltageChecks = VoltageChecks()
        currentDiagnostics = Diagnostics()
        currentRecommendations = [Recommendation(id: UUID(), index: 0, text: "")]
    }
    
    func saveCurrentAuditSession() {
        // TODO: Implement saving current session to Core Data
        // This would create an Audit entity and related entries
    }
    
    // MARK: - Draft Management
    func loadDrafts() {
        print("Loading drafts...")
        
        // First, let's check if there are any audits at all
        let allAuditsRequest: NSFetchRequest<Audit> = Audit.fetchRequest()
        do {
            let allAudits = try context.fetch(allAuditsRequest)
            print("Total audits in database: \(allAudits.count)")
            for audit in allAudits {
                print("All Audit: ID=\(audit.id?.uuidString ?? "nil"), Status=\(audit.status ?? "nil"), Farm=\(audit.farmName ?? "nil"), Tech=\(audit.technician ?? "nil")")
            }
        } catch {
            print("Error loading all audits: \(error)")
        }
        
        // Now load drafts specifically
        let request: NSFetchRequest<Audit> = Audit.fetchRequest()
        request.predicate = NSPredicate(format: "status == %@", AuditStatus.draft.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Audit.updatedAt, ascending: false)]
        
        do {
            let draftAudits = try context.fetch(request)
            print("Found \(draftAudits.count) draft audits")
            
            // Debug: Print all draft audits to see what's in the database
            for audit in draftAudits {
                print("Draft Audit: ID=\(audit.id?.uuidString ?? "nil"), Status=\(audit.status ?? "nil"), Farm=\(audit.farmName ?? "nil"), Tech=\(audit.technician ?? "nil")")
            }
            
            drafts = draftAudits
            print("Loaded \(drafts.count) drafts")
        } catch {
            print("Error loading drafts: \(error)")
        }
    }
    
    // MARK: - Test Methods
    func createTestDraft() {
        print("Creating test draft...")
        let testDraft = saveDraft(
            farmId: "TEST001",
            farmName: "Test Farm",
            technician: "Test Technician",
            notes: "Test draft created for debugging"
        )
        
        if let draft = testDraft {
            print("Test draft created successfully: \(draft.id?.uuidString ?? "unknown")")
        } else {
            print("Failed to create test draft")
        }
    }
    
    // MARK: - Save Draft
    func saveDraft(farmId: String, farmName: String, technician: String, notes: String = "") -> Audit? {
        print("Saving draft with farmId: \(farmId), farmName: \(farmName), technician: \(technician)")
        
        let audit = Audit(context: context)
        audit.id = UUID()
        audit.farmId = farmId
        audit.farmName = farmName
        audit.technician = technician
        audit.notes = notes
        audit.status = AuditStatus.draft.rawValue
        audit.date = Date()
        audit.createdAt = Date()
        audit.updatedAt = Date()
        
        // Save current session data as draft entries
        saveCurrentSessionAsDraftEntries(audit: audit)
        
        do {
            try context.save()
            print("Draft saved successfully with ID: \(audit.id?.uuidString ?? "unknown")")
            loadDrafts() // Refresh drafts list
            return audit
        } catch {
            print("Error saving draft: \(error)")
            context.delete(audit)
            return nil
        }
    }
    
    // MARK: - Load Draft into Current Session
    func loadDraft(_ audit: Audit) {
        // This method is now deprecated in favor of AuditViewModel
        // The routing system will handle loading drafts directly into AuditViewModel
        print("loadDraft called - this method is deprecated. Use AuditViewModel instead.")
    }
    
    // MARK: - Update Draft
    func updateDraft(_ audit: Audit) {
        audit.updatedAt = Date()
        
        do {
            try context.save()
        } catch {
            print("Error updating draft: \(error)")
        }
    }
    
    // MARK: - Delete Draft
    func deleteDraft(_ audit: Audit) {
        context.delete(audit)
        
        do {
            try context.save()
            loadDrafts() // Refresh drafts list
        } catch {
            print("Error deleting draft: \(error)")
        }
    }
    
    // MARK: - Complete Draft
    func completeDraft(_ audit: Audit) {
        audit.status = AuditStatus.completed.rawValue
        audit.updatedAt = Date()
        
        do {
            try context.save()
            loadDrafts() // Refresh drafts list
            loadData() // Refresh audits list
        } catch {
            print("Error completing draft: \(error)")
        }
    }
    
    // MARK: - Autosave Binding
    func bind(_ vm: AuditViewModel) {
        // This method will be used to bind AuditViewModel for autosave functionality
        // The actual autosave is now handled within AuditViewModel itself
        print("Binding AuditViewModel for autosave")
    }
    
    // MARK: - Private Helper Methods
    private func saveCurrentSessionAsDraftEntries(audit: Audit) {
        // This method is now deprecated as AuditViewModel handles data persistence
        print("saveCurrentSessionAsDraftEntries called - this method is deprecated.")
    }
    
    private func loadDraftIntoCurrentSession(audit: Audit) {
        // This method is now deprecated as AuditViewModel handles data loading
        print("loadDraftIntoCurrentSession called - this method is deprecated.")
    }
    
    private func updateDraftEntries(audit: Audit) {
        // Update draft entries with current session data
        // This is a simplified version - in a full implementation,
        // you'd update all the draft entries with current session data
    }
    
    private func clearCurrentSession() {
        currentFarmInfo = nil
        currentMilkingTimeRows = []
        currentDetacherSettings = nil
        currentPulsatorRows = []
        currentPulsationAverage = nil
        currentVoltageChecks = nil
        currentDiagnostics = nil
        currentRecommendations = []
    }
    
    // MARK: - Data Loading
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        do {
            farms = try loadFarms()
            audits = try loadAudits()
            loadDrafts() // Load drafts
            isLoading = false
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func loadFarms() throws -> [Farm] {
        let request: NSFetchRequest<Farm> = Farm.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Farm.name, ascending: true)]
        return try context.fetch(request)
    }
    
    private func loadAudits() throws -> [Audit] {
        let request: NSFetchRequest<Audit> = Audit.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Audit.date, ascending: false)]
        return try context.fetch(request)
    }
    
    // MARK: - Farm Operations
    @discardableResult
    func createFarm(name: String, location: String, contactPerson: String, phone: String) throws -> Farm {
        let farm = Farm(context: context)
        farm.id = UUID()
        farm.name = name
        farm.location = location
        farm.contactPerson = contactPerson
        farm.phone = phone
        farm.createdAt = Date()
        
        try context.save()
        farms.append(farm)
        return farm
    }
    
    func updateFarm(_ farm: Farm) throws {
        try context.save()
        loadData()
    }
    
    func deleteFarm(_ farm: Farm) throws {
        context.delete(farm)
        try context.save()
        loadData()
    }
    
    // MARK: - Audit Operations
    func createAudit(farmId: String, farmName: String, technician: String, notes: String) throws -> Audit {
        let audit = Audit(context: context)
        audit.id = UUID()
        audit.farmId = farmId
        audit.farmName = farmName
        audit.date = Date()
        audit.technician = technician
        audit.notes = notes
        audit.createdAt = Date()
        audit.updatedAt = Date()
        
        try context.save()
        audits.insert(audit, at: 0)
        return audit
    }
    
    func updateAudit(_ audit: Audit) throws {
        audit.updatedAt = Date()
        try context.save()
        loadData()
    }
    
    func deleteAudit(_ audit: Audit) throws {
        context.delete(audit)
        try context.save()
        loadData()
    }
    
    // MARK: - Audit Entry Operations
    @discardableResult
    func addAuditEntry(to audit: Audit, parameter: String, value: Double, unit: String, category: String) throws -> AuditEntry {
        let entry = AuditEntry(context: context)
        entry.id = UUID()
        entry.parameter = parameter
        entry.value = value
        entry.unit = unit
        entry.category = category
        entry.createdAt = Date()
        entry.audit = audit
        
        // Calculate status based on guidelines
        let status = AuditGuidelines.evaluateParameter(parameter, value: value)
        entry.status = status.rawValue
        
        try context.save()
        return entry
    }
    
    func updateAuditEntry(_ entry: AuditEntry) throws {
        // Recalculate status if value changed
        if let parameter = entry.parameter {
            let status = AuditGuidelines.evaluateParameter(parameter, value: entry.value)
            entry.status = status.rawValue
        }
        
        try context.save()
    }
    
    func deleteAuditEntry(_ entry: AuditEntry) throws {
        context.delete(entry)
        try context.save()
    }
    
    // MARK: - Teat Score Operations
    func addTeatScore(to audit: Audit, cowId: String, score: Int16, imageKey: String?, notes: String) throws -> TeatScore {
        let teatScore = TeatScore(context: context)
        teatScore.id = UUID()
        teatScore.cowId = cowId
        teatScore.score = score
        teatScore.imageKey = imageKey
        teatScore.notes = notes
        teatScore.createdAt = Date()
        teatScore.audit = audit
        
        try context.save()
        return teatScore
    }
    
    func updateTeatScore(_ teatScore: TeatScore) throws {
        try context.save()
    }
    
    func deleteTeatScore(_ teatScore: TeatScore) throws {
        context.delete(teatScore)
        try context.save()
    }
    
    // MARK: - Query Methods
    func getAudits(for farm: Farm) -> [Audit] {
        return audits.filter { $0.farmId == farm.id?.uuidString }
    }
    
    func getAuditEntries(for audit: Audit) -> [AuditEntry] {
        guard let entries = audit.entries?.allObjects as? [AuditEntry] else {
            return []
        }
        return entries.sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
    }
    
    func getTeatScores(for audit: Audit) -> [TeatScore] {
        guard let scores = audit.teatScores?.allObjects as? [TeatScore] else {
            return []
        }
        return scores.sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
    }
    
    // MARK: - Statistics
    func getAuditStatistics(for farm: Farm? = nil) -> AuditStatistics {
        let relevantAudits = farm != nil ? getAudits(for: farm!) : audits
        
        var totalAudits = 0
        var criticalIssues = 0
        var warningIssues = 0
        var normalReadings = 0
        
        for audit in relevantAudits {
            totalAudits += 1
            let entries = getAuditEntries(for: audit)
            
            for entry in entries {
                if let status = entry.status {
                    switch status {
                    case "Critical":
                        criticalIssues += 1
                    case "Low", "High":
                        warningIssues += 1
                    case "Normal":
                        normalReadings += 1
                    default:
                        break
                    }
                }
            }
        }
        
        return AuditStatistics(
            totalAudits: totalAudits,
            criticalIssues: criticalIssues,
            warningIssues: warningIssues,
            normalReadings: normalReadings
        )
    }
}

// MARK: - Audit Statistics
struct AuditStatistics {
    let totalAudits: Int
    let criticalIssues: Int
    let warningIssues: Int
    let normalReadings: Int
    
    var totalReadings: Int {
        return criticalIssues + warningIssues + normalReadings
    }
    
    var criticalPercentage: Double {
        guard totalReadings > 0 else { return 0 }
        return Double(criticalIssues) / Double(totalReadings) * 100
    }
    
    var warningPercentage: Double {
        guard totalReadings > 0 else { return 0 }
        return Double(warningIssues) / Double(totalReadings) * 100
    }
    
    var normalPercentage: Double {
        guard totalReadings > 0 else { return 0 }
        return Double(normalReadings) / Double(totalReadings) * 100
    }
} 