import Foundation

// MARK: - Audit Parameter Guidelines
struct AuditGuidelines {
    
    // MARK: - Parameter Categories
    enum ParameterCategory: String, CaseIterable {
        case vacuum = "Vacuum"
        case pulsation = "Pulsation"
        case flow = "Flow"
        case detacher = "Detacher"
        case general = "General"
    }
    
    // MARK: - Parameter Definitions
    struct ParameterDefinition {
        let name: String
        let category: ParameterCategory
        let unit: String
        let minValue: Double
        let maxValue: Double
        let targetValue: Double?
        let description: String
        let recommendations: [String]
        
        var status: ParameterStatus {
            return .normal // Will be calculated based on value
        }
    }
    
    // MARK: - Parameter Status
    enum ParameterStatus: String, CaseIterable {
        case low = "Low"
        case normal = "Normal"
        case high = "High"
        case critical = "Critical"
        
        var color: String {
            switch self {
            case .low: return "orange"
            case .normal: return "green"
            case .high: return "orange"
            case .critical: return "red"
            }
        }
        
        var icon: String {
            switch self {
            case .low: return "exclamationmark.triangle"
            case .normal: return "checkmark.circle"
            case .high: return "exclamationmark.triangle"
            case .critical: return "xmark.circle"
            }
        }
    }
    
    // MARK: - Standard Parameters
    static let standardParameters: [ParameterDefinition] = [
        // Vacuum Parameters
        ParameterDefinition(
            name: "Claw Vacuum",
            category: .vacuum,
            unit: "in Hg",
            minValue: 12.5,
            maxValue: 15.0,
            targetValue: 13.5,
            description: "Vacuum level at the claw during milking",
            recommendations: [
                "Check vacuum regulator settings",
                "Ensure proper vacuum pump operation",
                "Verify no air leaks in system"
            ]
        ),
        
        ParameterDefinition(
            name: "Milk Line Vacuum",
            category: .vacuum,
            unit: "in Hg",
            minValue: 13.0,
            maxValue: 15.5,
            targetValue: 14.0,
            description: "Vacuum level in the main milk line",
            recommendations: [
                "Check vacuum pump capacity",
                "Verify milk line diameter and length",
                "Ensure proper receiver jar operation"
            ]
        ),
        
        ParameterDefinition(
            name: "Vacuum Reserve",
            category: .vacuum,
            unit: "in Hg",
            minValue: 2.0,
            maxValue: 5.0,
            targetValue: 3.0,
            description: "Difference between pump and claw vacuum",
            recommendations: [
                "Increase vacuum pump capacity if needed",
                "Check for air leaks",
                "Verify proper system design"
            ]
        ),
        
        // Pulsation Parameters
        ParameterDefinition(
            name: "Pulsation Rate",
            category: .pulsation,
            unit: "cycles/min",
            minValue: 50,
            maxValue: 65,
            targetValue: 60,
            description: "Number of pulsation cycles per minute",
            recommendations: [
                "Adjust pulsator settings",
                "Check pulsator air supply",
                "Verify pulsator timing"
            ]
        ),
        
        ParameterDefinition(
            name: "Pulsation Ratio",
            category: .pulsation,
            unit: "%",
            minValue: 60,
            maxValue: 70,
            targetValue: 65,
            description: "Percentage of cycle in milk phase",
            recommendations: [
                "Adjust pulsator ratio settings",
                "Check pulsator air pressure",
                "Verify proper pulsator operation"
            ]
        ),
        
        ParameterDefinition(
            name: "Pulsation Vacuum",
            category: .pulsation,
            unit: "in Hg",
            minValue: 10.0,
            maxValue: 12.0,
            targetValue: 11.0,
            description: "Vacuum during pulsation phase",
            recommendations: [
                "Check pulsator air supply",
                "Verify pulsator settings",
                "Ensure proper air line pressure"
            ]
        ),
        
        // Flow Parameters
        ParameterDefinition(
            name: "Peak Flow Rate",
            category: .flow,
            unit: "lbs/min",
            minValue: 6.0,
            maxValue: 12.0,
            targetValue: 9.0,
            description: "Maximum milk flow rate during milking",
            recommendations: [
                "Check liner condition and fit",
                "Verify proper cluster attachment",
                "Ensure cow comfort and preparation"
            ]
        ),
        
        ParameterDefinition(
            name: "Average Flow Rate",
            category: .flow,
            unit: "lbs/min",
            minValue: 3.0,
            maxValue: 6.0,
            targetValue: 4.5,
            description: "Average milk flow rate over entire milking",
            recommendations: [
                "Optimize milking routine",
                "Check liner condition",
                "Verify proper cluster removal timing"
            ]
        ),
        
        // Detacher Parameters
        ParameterDefinition(
            name: "Detach Flow Rate",
            category: .detacher,
            unit: "lbs/min",
            minValue: 0.5,
            maxValue: 1.5,
            targetValue: 1.0,
            description: "Flow rate at which detacher activates",
            recommendations: [
                "Adjust detacher sensitivity",
                "Check flow sensor operation",
                "Verify proper calibration"
            ]
        ),
        
        ParameterDefinition(
            name: "Detach Delay",
            category: .detacher,
            unit: "seconds",
            minValue: 0,
            maxValue: 3,
            targetValue: 1,
            description: "Delay before detacher activates",
            recommendations: [
                "Adjust detacher delay settings",
                "Check detacher operation",
                "Verify proper timing"
            ]
        ),
        
        // General Parameters
        ParameterDefinition(
            name: "System Air Leak",
            category: .general,
            unit: "cfm",
            minValue: 0,
            maxValue: 5,
            targetValue: 0,
            description: "Air leakage in the system",
            recommendations: [
                "Check all connections and seals",
                "Inspect milk lines for damage",
                "Verify receiver jar operation"
            ]
        ),
        
        ParameterDefinition(
            name: "Liner Slip Rate",
            category: .general,
            unit: "%",
            minValue: 0,
            maxValue: 5,
            targetValue: 0,
            description: "Percentage of liners that slip during milking",
            recommendations: [
                "Check liner condition and fit",
                "Verify proper cluster attachment",
                "Ensure adequate vacuum level"
            ]
        )
    ]
    
    // MARK: - Helper Methods
    static func getParameterDefinition(for name: String) -> ParameterDefinition? {
        return standardParameters.first { $0.name == name }
    }
    
    static func getParameters(for category: ParameterCategory) -> [ParameterDefinition] {
        return standardParameters.filter { $0.category == category }
    }
    
    static func evaluateParameter(_ name: String, value: Double) -> ParameterStatus {
        guard let definition = getParameterDefinition(for: name) else {
            return .normal
        }
        
        if value < definition.minValue {
            return value < (definition.minValue - (definition.maxValue - definition.minValue) * 0.2) ? .critical : .low
        } else if value > definition.maxValue {
            return value > (definition.maxValue + (definition.maxValue - definition.minValue) * 0.2) ? .critical : .high
        } else {
            return .normal
        }
    }
    
    static func getRecommendations(for name: String, value: Double) -> [String] {
        guard let definition = getParameterDefinition(for: name) else {
            return []
        }
        
        let status = evaluateParameter(name, value: value)
        var recommendations = definition.recommendations
        
        // Add specific recommendations based on status
        switch status {
        case .low:
            recommendations.append("Value is below recommended range - investigate cause")
        case .high:
            recommendations.append("Value is above recommended range - investigate cause")
        case .critical:
            recommendations.append("CRITICAL: Value is significantly outside safe range - immediate action required")
        case .normal:
            recommendations.append("Value is within normal range")
        }
        
        return recommendations
    }
} 