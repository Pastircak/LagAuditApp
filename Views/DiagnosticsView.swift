import SwiftUI

struct DiagnosticsView: View {
    @ObservedObject var auditViewModel: AuditViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CardView(header: "Operating Vacuum & Unit Fall-Off Tests") {
                    VStack(spacing: 12) {
                        StepRow(step: 1, title: "All units operating",
                                receiver: Binding(
                                    get: { auditViewModel.diagnostics?.step1ReceiverVac },
                                    set: { 
                                        if auditViewModel.diagnostics == nil {
                                            auditViewModel.diagnostics = Diagnostics()
                                        }
                                        auditViewModel.diagnostics?.step1ReceiverVac = $0 
                                    }
                                ),
                                regulator: Binding(
                                    get: { auditViewModel.diagnostics?.step1RegulatorVac },
                                    set: { 
                                        if auditViewModel.diagnostics == nil {
                                            auditViewModel.diagnostics = Diagnostics()
                                        }
                                        auditViewModel.diagnostics?.step1RegulatorVac = $0 
                                    }
                                ),
                                pulsator: Binding(
                                    get: { auditViewModel.diagnostics?.step1PulsatorAirlineVac },
                                    set: { 
                                        if auditViewModel.diagnostics == nil {
                                            auditViewModel.diagnostics = Diagnostics()
                                        }
                                        auditViewModel.diagnostics?.step1PulsatorAirlineVac = $0 
                                    }
                                ),
                                pumpInlet: Binding(
                                    get: { auditViewModel.diagnostics?.step1PumpInletVac },
                                    set: { 
                                        if auditViewModel.diagnostics == nil {
                                            auditViewModel.diagnostics = Diagnostics()
                                        }
                                        auditViewModel.diagnostics?.step1PumpInletVac = $0 
                                    }
                                ),
                                farmGauge: .constant(nil))
                        StepRow(step: 2, title: "Avg vac w/ 1 unit open 5-20 s",
                                receiver: Binding(
                                    get: { auditViewModel.diagnostics?.step2ReceiverVac },
                                    set: { 
                                        if auditViewModel.diagnostics == nil {
                                            auditViewModel.diagnostics = Diagnostics()
                                        }
                                        auditViewModel.diagnostics?.step2ReceiverVac = $0 
                                    }
                                ),
                                regulator: Binding(
                                    get: { auditViewModel.diagnostics?.step2RegulatorVac },
                                    set: { 
                                        if auditViewModel.diagnostics == nil {
                                            auditViewModel.diagnostics = Diagnostics()
                                        }
                                        auditViewModel.diagnostics?.step2RegulatorVac = $0 
                                    }
                                ),
                                calc: overUnder2)
                        StepRow(step: 3, title: "Avg min vac as 1 unit opens",
                                receiver: Binding(
                                    get: { auditViewModel.diagnostics?.step3ReceiverVac },
                                    set: { 
                                        if auditViewModel.diagnostics == nil {
                                            auditViewModel.diagnostics = Diagnostics()
                                        }
                                        auditViewModel.diagnostics?.step3ReceiverVac = $0 
                                    }
                                ),
                                calc: overUnder3)
                        StepRow(step: 4, title: "Avg max vac as 1 unit closes",
                                receiver: Binding(
                                    get: { auditViewModel.diagnostics?.step4ReceiverVac },
                                    set: { 
                                        if auditViewModel.diagnostics == nil {
                                            auditViewModel.diagnostics = Diagnostics()
                                        }
                                        auditViewModel.diagnostics?.step4ReceiverVac = $0 
                                    }
                                ),
                                calc: overUnder4)
                        StepRow(step: 5, title: "Avg vac w/ 2 units open 5-20 s",
                                receiver: Binding(
                                    get: { auditViewModel.diagnostics?.step5ReceiverVac },
                                    set: { 
                                        if auditViewModel.diagnostics == nil {
                                            auditViewModel.diagnostics = Diagnostics()
                                        }
                                        auditViewModel.diagnostics?.step5ReceiverVac = $0 
                                    }
                                ),
                                regulator: Binding(
                                    get: { auditViewModel.diagnostics?.step5RegulatorVac },
                                    set: { 
                                        if auditViewModel.diagnostics == nil {
                                            auditViewModel.diagnostics = Diagnostics()
                                        }
                                        auditViewModel.diagnostics?.step5RegulatorVac = $0 
                                    }
                                ),
                                calc: overUnder5)
                        StepRow(step: 6, title: "Min vac as 2 units open",
                                receiver: Binding(
                                    get: { auditViewModel.diagnostics?.step6ReceiverVac },
                                    set: { 
                                        if auditViewModel.diagnostics == nil {
                                            auditViewModel.diagnostics = Diagnostics()
                                        }
                                        auditViewModel.diagnostics?.step6ReceiverVac = $0 
                                    }
                                ),
                                calc: overUnder6)
                        StepRow(step: 7, title: "Max vac as 2 units close",
                                receiver: Binding(
                                    get: { auditViewModel.diagnostics?.step7ReceiverVac },
                                    set: { 
                                        if auditViewModel.diagnostics == nil {
                                            auditViewModel.diagnostics = Diagnostics()
                                        }
                                        auditViewModel.diagnostics?.step7ReceiverVac = $0 
                                    }
                                ),
                                calc: overUnder7)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            // Initialize diagnostics if not already present
            if auditViewModel.diagnostics == nil {
                auditViewModel.diagnostics = Diagnostics()
            }
        }
    }
    
    // MARK: - Derived properties
    private var overUnder2: Double? { 
        diff(auditViewModel.diagnostics?.step2ReceiverVac, 
             auditViewModel.diagnostics?.step2RegulatorVac) 
    }
    private var overUnder3: Double? { 
        diff(auditViewModel.diagnostics?.step3ReceiverVac) 
    }
    private var overUnder4: Double? { 
        revDiff(auditViewModel.diagnostics?.step4ReceiverVac) 
    }
    private var overUnder5: Double? { 
        diff(auditViewModel.diagnostics?.step5ReceiverVac, 
             auditViewModel.diagnostics?.step5RegulatorVac) 
    }
    private var overUnder6: Double? { 
        diff(auditViewModel.diagnostics?.step6ReceiverVac) 
    }
    private var overUnder7: Double? { 
        revDiff(auditViewModel.diagnostics?.step7ReceiverVac) 
    }
    
    // MARK: - Helper functions
    private func diff(_ receiver: Double?, _ regulator: Double? = nil) -> Double? {
        guard let receiver = receiver else { return nil }
        if let regulator = regulator {
            return receiver - regulator
        }
        return receiver - (auditViewModel.diagnostics?.step1ReceiverVac ?? 0)
    }
    
    private func revDiff(_ receiver: Double?) -> Double? {
        guard let receiver = receiver else { return nil }
        return (auditViewModel.diagnostics?.step1ReceiverVac ?? 0) - receiver
    }
}

struct StepRow: View {
    let step: Int
    let title: String
    let receiver: Binding<Double?>
    let regulator: Binding<Double?>?
    let pulsator: Binding<Double?>?
    let pumpInlet: Binding<Double?>?
    let farmGauge: Binding<Double?>?
    let calc: Double?
    
    init(step: Int, title: String, receiver: Binding<Double?>, regulator: Binding<Double?>? = nil, pulsator: Binding<Double?>? = nil, pumpInlet: Binding<Double?>? = nil, farmGauge: Binding<Double?>? = nil, calc: Double? = nil) {
        self.step = step
        self.title = title
        self.receiver = receiver
        self.regulator = regulator
        self.pulsator = pulsator
        self.pumpInlet = pumpInlet
        self.farmGauge = farmGauge
        self.calc = calc
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Step \(step)")
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
                if let calc = calc {
                    Text("Δ: \(String(format: "%.1f", calc))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                VacuumField(label: "Receiver", value: receiver)
                
                if let regulator = regulator {
                    VacuumField(label: "Regulator", value: regulator)
                }
                
                if let pulsator = pulsator {
                    VacuumField(label: "Pulsator", value: pulsator)
                }
                
                if let pumpInlet = pumpInlet {
                    VacuumField(label: "Pump Inlet", value: pumpInlet)
                }
                
                if let farmGauge = farmGauge {
                    VacuumField(label: "Farm Gauge", value: farmGauge)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
    }
}

struct VacuumField: View {
    let label: String
    @Binding var value: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("--", text: Binding(
                get: { value.map { String(format: "%.1f", $0) } ?? "" },
                set: { newValue in
                    if let doubleValue = Double(newValue) {
                        value = doubleValue
                    } else if newValue.isEmpty {
                        value = nil
                    }
                }
            ))
            .keyboardType(.decimalPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
} 