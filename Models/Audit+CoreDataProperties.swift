//
//  Audit+CoreDataProperties.swift
//  LagAuditApp
//
//  Created by Ryan Pastircak on 7/21/25.
//
//

import Foundation
import CoreData


extension Audit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Audit> {
        return NSFetchRequest<Audit>(entityName: "Audit")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var farmId: String?
    @NSManaged public var farmName: String?
    @NSManaged public var date: Date?
    @NSManaged public var technician: String?
    @NSManaged public var notes: String?
    @NSManaged public var status: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var farmInfoData: Data?
    @NSManaged public var milkingTimeData: Data?
    @NSManaged public var detacherSettingsData: Data?
    @NSManaged public var pulsatorData: Data?
    @NSManaged public var pulsationData: Data?
    @NSManaged public var voltageChecksData: Data?
    @NSManaged public var diagnosticsData: Data?
    @NSManaged public var recommendationsData: Data?
    @NSManaged public var entries: NSSet?
    @NSManaged public var farm: Farm?
    @NSManaged public var teatScores: NSSet?

}

// MARK: Generated accessors for entries
extension Audit {

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: AuditEntry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: AuditEntry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)

}

// MARK: Generated accessors for teatScores
extension Audit {

    @objc(addTeatScoresObject:)
    @NSManaged public func addToTeatScores(_ value: TeatScore)

    @objc(removeTeatScoresObject:)
    @NSManaged public func removeFromTeatScores(_ value: TeatScore)

    @objc(addTeatScores:)
    @NSManaged public func addToTeatScores(_ values: NSSet)

    @objc(removeTeatScores:)
    @NSManaged public func removeFromTeatScores(_ values: NSSet)

}

extension Audit : Identifiable {

}
