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
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadData()
    }
    
    // MARK: - Data Loading
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        do {
            farms = try loadFarms()
            audits = try loadAudits()
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