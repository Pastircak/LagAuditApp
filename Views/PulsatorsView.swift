import SwiftUI

struct PulsatorsView: View {
    @State private var pulsators: [PulsatorRow] = (1...6).map { PulsatorRow(number: Int16($0)) }
    @State private var averages = PulsationAverage()
    @State private var voltageChecks = VoltageChecks()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Pulsator Tests")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: addPulsator) {
                        Label("Add Row", systemImage: "plus.circle")
                    }
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(pulsators.indices, id: \ .self) { idx in
                        PulsatorRowCard(pulsator: $pulsators[idx], onDelete: { removePulsator(at: idx) }, onDuplicate: { duplicatePulsator(at: idx) }, showDelete: pulsators.count > 1)
                    }
                }
                CardView(header: "Averages") {
                    PulsationAverageFields(average: $averages)
                }
                CardView(header: "Voltage Checks") {
                    VoltageChecksFields(voltage: $voltageChecks)
                }
            }
            .padding()
        }
    }
    
    private func addPulsator() {
        let nextNumber = (pulsators.last?.number ?? 0) + 1
        pulsators.append(PulsatorRow(number: nextNumber))
    }
    private func removePulsator(at idx: Int) {
        pulsators.remove(at: idx)
    }
    private func duplicatePulsator(at idx: Int) {
        let row = pulsators[idx]
        let newRow = PulsatorRow(number: (pulsators.last?.number ?? 0) + 1,
                                 ratioFront: row.ratioFront, ratioRear: row.ratioRear,
                                 aFront: row.aFront, aRear: row.aRear,
                                 bFront: row.bFront, bRear: row.bRear,
                                 cFront: row.cFront, cRear: row.cRear,
                                 dFront: row.dFront, dRear: row.dRear,
                                 rate: row.rate)
        pulsators.append(newRow)
    }
}

struct PulsatorRowCard: View {
    @Binding var pulsator: PulsatorRow
    var onDelete: () -> Void
    var onDuplicate: () -> Void
    var showDelete: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Pulsator \(pulsator.number)")
                    .font(.headline)
                Spacer()
                if showDelete {
                    Button(action: onDelete) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                    .accessibilityLabel("Delete Row")
                }
                Button(action: onDuplicate) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
                .accessibilityLabel("Duplicate Row")
            }
            PulsatorMetricField(label: "Ratio Front", value: $pulsator.ratioFront)
            PulsatorMetricField(label: "Ratio Rear", value: $pulsator.ratioRear)
            PulsatorMetricField(label: "A phase (ms) Front", value: $pulsator.aFront)
            PulsatorMetricField(label: "A phase (ms) Rear", value: $pulsator.aRear)
            PulsatorMetricField(label: "B phase (ms) Front", value: $pulsator.bFront)
            PulsatorMetricField(label: "B phase (ms) Rear", value: $pulsator.bRear)
            PulsatorMetricField(label: "C phase (ms) Front", value: $pulsator.cFront)
            PulsatorMetricField(label: "C phase (ms) Rear", value: $pulsator.cRear)
            PulsatorMetricField(label: "D phase (ms) Front", value: $pulsator.dFront)
            PulsatorMetricField(label: "D phase (ms) Rear", value: $pulsator.dRear)
            PulsatorMetricField(label: "Rate (cpm)", value: $pulsator.rate)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct PulsatorMetricField: View {
    let label: String
    @Binding var value: Double?
    @State private var textValue: String = ""
    var body: some View {
        HStack {
            Text(label)
                .frame(width: 140, alignment: .leading)
            Spacer()
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

struct PulsationAverageFields: View {
    @Binding var average: PulsationAverage
    var body: some View {
        VStack(spacing: 8) {
            PulsatorMetricField(label: "Ratio 1", value: $average.ratio1)
            PulsatorMetricField(label: "Ratio 2", value: $average.ratio2)
            PulsatorMetricField(label: "A phase", value: $average.aPhase)
            PulsatorMetricField(label: "B phase", value: $average.bPhase)
            PulsatorMetricField(label: "C phase", value: $average.cPhase)
            PulsatorMetricField(label: "D phase", value: $average.dPhase)
            PulsatorMetricField(label: "Rate", value: $average.rate)
        }
    }
}

struct VoltageChecksFields: View {
    @Binding var voltage: VoltageChecks
    var body: some View {
        VStack(spacing: 8) {
            PulsatorMetricField(label: "At Control", value: $voltage.atControl)
            PulsatorMetricField(label: "At Last", value: $voltage.atLast)
            PulsatorMetricField(label: "At Other", value: $voltage.atOther)
        }
    }
} 