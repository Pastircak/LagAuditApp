import Foundation
import CoreData

// MARK: - Audit Status
enum AuditStatus: String, CaseIterable {
    case normal = "Normal"
    case warning = "Warning"
    case critical = "Critical"
    
    var color: String {
        switch self {
        case .normal: return "green"
        case .warning: return "orange"
        case .critical: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .normal: return "checkmark.circle"
        case .warning: return "exclamationmark.triangle"
        case .critical: return "xmark.circle"
        }
    }
}

// MARK: - Audit Data Structure
struct AuditData {
    let farm: Farm?
    let technician: String
    let date: Date
    let entries: [AuditEntryData]
    
    init(farm: Farm?, technician: String, date: Date, entries: [AuditEntryData]) {
        self.farm = farm
        self.technician = technician
        self.date = date
        self.entries = entries
    }
}

// MARK: - Audit Entry Data
struct AuditEntryData {
    let parameter: String
    let value: String
    let status: AuditStatus
    let recommendation: String?
    
    init(parameter: String, value: String, status: AuditStatus, recommendation: String? = nil) {
        self.parameter = parameter
        self.value = value
        self.status = status
        self.recommendation = recommendation
    }
}

// MARK: - Audit Form Structure
struct AuditForm {
    struct Section {
        let title: String
        let subtitle: String?
        let parameters: [String]
        
        init(title: String, subtitle: String? = nil, parameters: [String]) {
            self.title = title
            self.subtitle = subtitle
            self.parameters = parameters
        }
    }
    
    static let sections: [Section] = [
        Section(
            title: "Vacuum System",
            subtitle: "Critical vacuum parameters",
            parameters: ["Claw Vacuum", "Milk Line Vacuum", "Vacuum Reserve"]
        ),
        Section(
            title: "Pulsation",
            subtitle: "Pulsation system parameters",
            parameters: ["Pulsation Rate", "Pulsation Ratio", "Pulsation Vacuum"]
        ),
        Section(
            title: "Flow Rates",
            subtitle: "Milk flow parameters",
            parameters: ["Peak Flow Rate", "Average Flow Rate"]
        ),
        Section(
            title: "Detacher",
            subtitle: "Automatic detacher settings",
            parameters: ["Detach Flow Rate", "Detach Delay"]
        )
    ]
}

// MARK: - New Audit Data Models (Scaffold)

// struct Audit: Identifiable, Codable {
//     var id: UUID
//     var createdAt: Date
//     var farmInfo: FarmInfo
//     var milkingTimeRows: [MilkingTimeRow]
//     var detacher: DetacherSettings
//     var pulsators: [PulsatorRow]
//     var pulsationAverages: PulsationAverage
//     var voltageChecks: VoltageChecks
//     var diagnostics: Diagnostics
//     var recommendations: [Recommendation]
//     var syncStatus: SyncState
// }

struct FarmInfo: Codable {
    var dairyName, address, city, state, zip: String
    var date: Date
    var preparedBy, contactName, phone, email: String
    var numberOfCows: Int16
    var numberOfStalls: Int16
    var milkingFrequency: Int8
    var parlorConfig: ParlorType
    var linerType: LinerType
    var milkHoseID: HoseSize
    var milkProductionLbs: Double?
    var scc: Int32?
    var systemType: SystemType
    var milkLineIDs: [String]
    var milkLineSlope: Double?
    var vacuumPumpHP: Double?
    var hasVFD: Bool?
}

struct MilkingTimeRow: Codable, Identifiable {
    var id = UUID()
    var position: Int16
    var avgVac: Double?
    var maxVac: Double?
    var minVac: Double?
    var fluctuation: Double?
    var flowRate: Double?
    var stripYield: Double?
    var stimulationTime: Double?
}

struct DetacherSettings: Codable {
    var clusterRemovalDelay: Double?
    var blinkTimeDelay: Double?
    var detachFlowSetting: Double?
    var letDownDelay: Double?
    var notes: String
}

struct PulsatorRow: Codable, Identifiable {
    var id = UUID()
    var number: Int16
    var ratioFront: Double?
    var ratioRear: Double?
    var aFront, aRear, bFront, bRear, cFront, cRear, dFront, dRear: Double?
    var rate: Double?
}

struct PulsationAverage: Codable {
    var ratio1: Double?
    var ratio2: Double?
    var aPhase: Double?
    var bPhase: Double?
    var cPhase: Double?
    var dPhase: Double?
    var rate: Double?
}

struct VoltageChecks: Codable {
    var atControl: Double?
    var atLast: Double?
    var atOther: Double?
}

struct Diagnostics: Codable {
    var step1ReceiverVac: Double?
    var step1RegulatorVac: Double?
    var step1PulsatorAirlineVac: Double?
    var step1PumpInletVac: Double?
    var step1FarmGauge: Double?
    var step2ReceiverVac: Double?
    var step2RegulatorVac: Double?
    var step3ReceiverVac: Double?
    var step3RegulatorVac: Double?
    var step4ReceiverVac: Double?
    var step4RegulatorVac: Double?
    var step5ReceiverVac: Double?
    var step5RegulatorVac: Double?
    var step6ReceiverVac: Double?
    var step6RegulatorVac: Double?
    var step7ReceiverVac: Double?
    var step7RegulatorVac: Double?
    // Derived/calculated properties can be added as computed vars
}

struct Recommendation: Codable, Identifiable {
    var id = UUID()
    var index: Int8
    var text: String
}

// MARK: - Supporting Types

enum SyncState: String, Codable {
    case local, syncing, remote
}

enum ParlorType: String, Codable, CaseIterable {
    case rotary, parallel, herringbone, robot, other
}

enum LinerType: String, Codable, CaseIterable {
    case classic, other
}

enum HoseSize: String, Codable, CaseIterable {
    case fiveEighths = "5/8\""
    case threeQuarters = "3/4\""
    case sevenEighths = "7/8\""
}

enum SystemType: String, Codable, CaseIterable {
    case highLine, midLine, lowLine, singleTop, doubleLoop, other
}

import SwiftUI 

// MARK: - Audit Section Enum (Single Source of Truth)
enum AuditSection: String, CaseIterable, Identifiable {
    case farmInfo, milkingTime, detachers, pulsators, diagnostics, recommendations, overview
    var id: String { rawValue }
    var title: String {
        switch self {
        case .farmInfo: return "Farm Info"
        case .milkingTime: return "Milking Time"
        case .detachers: return "Detachers"
        case .pulsators: return "Pulsators"
        case .diagnostics: return "Diagnostics"
        case .recommendations: return "Recommendations"
        case .overview: return "Overview"
        }
    }
} 