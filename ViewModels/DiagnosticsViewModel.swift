import Foundation
import Combine

class DiagnosticsViewModel: ObservableObject {
    // Step 1 (all units operating)
    @Published var step1Receiver: Double? = nil
    @Published var step1Regulator: Double? = nil
    @Published var step1Pulsator: Double? = nil
    @Published var step1PumpInlet: Double? = nil
    @Published var step1FarmGauge: Double? = nil
    // Step 2
    @Published var step2Receiver: Double? = nil
    @Published var step2Regulator: Double? = nil
    // Step 3
    @Published var step3Receiver: Double? = nil
    // Step 4
    @Published var step4Receiver: Double? = nil
    // Step 5
    @Published var step5Receiver: Double? = nil
    @Published var step5Regulator: Double? = nil
    // Step 6
    @Published var step6Receiver: Double? = nil
    // Step 7
    @Published var step7Receiver: Double? = nil
    
    // MARK: - Derived properties
    var overUnder2: Double? { diff(step2Receiver) }
    var overUnder3: Double? { diff(step3Receiver) }
    var overUnder4: Double? { revDiff(step4Receiver) }
    var overUnder5: Double? { diff(step5Receiver) }
    var overUnder6: Double? { diff(step6Receiver) }
    var overUnder7: Double? { revDiff(step7Receiver) }
    
    private func diff(_ s: Double?) -> Double? {
        guard let s1 = step1Receiver, let sX = s else { return nil }
        return (s1 - sX).roundOne()
    }
    private func revDiff(_ s: Double?) -> Double? {
        guard let s1 = step1Receiver, let sX = s else { return nil }
        return (sX - s1).roundOne()
    }
}

extension Double {
    func roundOne() -> Double { (self * 10).rounded() / 10 }
} 