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

import SwiftUI 