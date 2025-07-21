import SwiftUI

struct DiagnosticsView: View {
    @StateObject private var vm = DiagnosticsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CardView(header: "Operating Vacuum & Unit Fall-Off Tests") {
                    VStack(spacing: 12) {
                        StepRow(step: 1, title: "All units operating",
                                receiver: $vm.step1Receiver,
                                regulator: $vm.step1Regulator,
                                pulsator: $vm.step1Pulsator,
                                pumpInlet: $vm.step1PumpInlet,
                                farmGauge: $vm.step1FarmGauge)
                        StepRow(step: 2, title: "Avg vac w/ 1 unit open 5-20 s",
                                receiver: $vm.step2Receiver,
                                regulator: $vm.step2Regulator,
                                calc: vm.overUnder2)
                        StepRow(step: 3, title: "Avg min vac as 1 unit opens",
                                receiver: $vm.step3Receiver,
                                calc: vm.overUnder3)
                        StepRow(step: 4, title: "Avg max vac as 1 unit closes",
                                receiver: $vm.step4Receiver,
                                calc: vm.overUnder4)
                        StepRow(step: 5, title: "Avg vac w/ 2 units open 5-20 s",
                                receiver: $vm.step5Receiver,
                                regulator: $vm.step5Regulator,
                                calc: vm.overUnder5)
                        StepRow(step: 6, title: "Min vac as 2 units open",
                                receiver: $vm.step6Receiver,
                                calc: vm.overUnder6)
                        StepRow(step: 7, title: "Max vac as 2 units close",
                                receiver: $vm.step7Receiver,
                                calc: vm.overUnder7)
                    }
                }
            }
            .padding()
        }
    }
}

struct StepRow: View {
    let step: Int
    let title: String
    @Binding var receiver: Double?
    @Binding var regulator: Double?
    @Binding var pulsator: Double?
    @Binding var pumpInlet: Double?
    @Binding var farmGauge: Double?
    var calc: Double? = nil
    
    init(step: Int, title: String,
         receiver: Binding<Double?>,
         regulator: Binding<Double?>? = nil,
         pulsator: Binding<Double?>? = nil,
         pumpInlet: Binding<Double?>? = nil,
         farmGauge: Binding<Double?>? = nil,
         calc: Double? = nil) {
        self.step = step
        self.title = title
        self._receiver = receiver
        self._regulator = regulator ?? .constant(nil)
        self._pulsator = pulsator ?? .constant(nil)
        self._pumpInlet = pumpInlet ?? .constant(nil)
        self._farmGauge = farmGauge ?? .constant(nil)
        self.calc = calc
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Step \(step): \(title)")
                .font(.subheadline)
                .fontWeight(.semibold)
            HStack(spacing: 12) {
                DiagnosticField(label: "Receiver", value: $receiver)
                if step == 1 || step == 2 || step == 5 {
                    DiagnosticField(label: "Regulator", value: $regulator)
                }
                if step == 1 {
                    DiagnosticField(label: "Pulsator", value: $pulsator)
                    DiagnosticField(label: "Pump Inlet", value: $pumpInlet)
                    DiagnosticField(label: "Farm Gauge", value: $farmGauge)
                }
                if step > 1 {
                    CalcField(calc: calc)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct DiagnosticField: View {
    let label: String
    @Binding var value: Double?
    @State private var textValue: String = ""
    var body: some View {
        HStack {
            Text(label)
                .frame(width: 90, alignment: .leading)
            TextField("--", text: Binding(
                get: {
                    if let v = value {
                        if textValue.isEmpty || Double(textValue) != v {
                            textValue = String(format: "%g", v)
                        }
                        return textValue
                    } else {
                        return ""
                    }
                },
                set: { newText in
                    textValue = newText
                    if let d = Double(newText) {
                        value = d
                    }
                }
            ))
            .keyboardType(.decimalPad)
            .frame(width: 60)
            .multilineTextAlignment(.trailing)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct CalcField: View {
    let calc: Double?
    var body: some View {
        HStack(spacing: 4) {
            if let c = calc {
                Text(String(format: "%+.1f", c))
                    .frame(width: 50, alignment: .trailing)
                RangeIndicator(value: c)
            } else {
                Text("--")
                    .frame(width: 50, alignment: .trailing)
                    .foregroundColor(.gray)
                RangeIndicator(value: nil)
            }
        }
    }
}

struct RangeIndicator: View {
    let value: Double?
    var body: some View {
        let color: Color
        let icon: String
        if let v = value {
            let absV = abs(v)
            if absV <= 0.6 {
                color = .green; icon = "checkmark.circle"
            } else if absV <= 1.0 {
                color = .yellow; icon = "exclamationmark.triangle"
            } else {
                color = .red; icon = "xmark.circle"
            }
        } else {
            color = .gray; icon = "questionmark.circle"
        }
        return Image(systemName: icon)
            .foregroundColor(color)
            .font(.title3)
            .accessibilityLabel(label(for: value))
    }
    private func label(for value: Double?) -> String {
        guard let v = value else { return "No value" }
        let absV = abs(v)
        if absV <= 0.6 { return "In range" }
        else if absV <= 1.0 { return "Warning" }
        else { return "Out of range" }
    }
} 