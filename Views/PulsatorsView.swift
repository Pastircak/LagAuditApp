import SwiftUI

struct PulsatorsView: View {
    @ObservedObject var auditViewModel: AuditViewModel
    
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
                    ForEach(auditViewModel.pulsatorRows.indices, id: \.self) { idx in
                        PulsatorRowCard(
                            pulsator: Binding(
                                get: { auditViewModel.pulsatorRows[idx] },
                                set: { auditViewModel.pulsatorRows[idx] = $0 }
                            ),
                            onDelete: { removePulsator(at: idx) },
                            onDuplicate: { duplicatePulsator(at: idx) },
                            showDelete: auditViewModel.pulsatorRows.count > 1
                        )
                    }
                }
                CardView(header: "Averages") {
                    PulsationAverageFields(average: Binding(
                        get: { auditViewModel.pulsationAverages ?? PulsationAverage() },
                        set: { auditViewModel.pulsationAverages = $0 }
                    ))
                }
                CardView(header: "Voltage Checks") {
                    VoltageChecksFields(voltage: Binding(
                        get: { auditViewModel.voltageChecks ?? VoltageChecks() },
                        set: { auditViewModel.voltageChecks = $0 }
                    ))
                }
            }
            .padding()
        }
    }
    
    private func addPulsator() {
        let nextNumber = (auditViewModel.pulsatorRows.last?.number ?? 0) + 1
        auditViewModel.pulsatorRows.append(PulsatorRow(number: nextNumber))
    }
    private func removePulsator(at idx: Int) {
        auditViewModel.pulsatorRows.remove(at: idx)
    }
    private func duplicatePulsator(at idx: Int) {
        let row = auditViewModel.pulsatorRows[idx]
        let newRow = PulsatorRow(number: (auditViewModel.pulsatorRows.last?.number ?? 0) + 1,
                                 ratioFront: row.ratioFront, ratioRear: row.ratioRear,
                                 aFront: row.aFront, aRear: row.aRear,
                                 bFront: row.bFront, bRear: row.bRear,
                                 cFront: row.cFront, cRear: row.cRear,
                                 dFront: row.dFront, dRear: row.dRear,
                                 rate: row.rate)
        auditViewModel.pulsatorRows.append(newRow)
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
            PulsatorMetricField(label: "Rate (ppm)", value: $pulsator.rate)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct PulsatorMetricField: View {
    let label: String
    @Binding var value: Double?
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .frame(width: 100, alignment: .leading)
            Spacer()
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
            .frame(width: 60)
            .multilineTextAlignment(.trailing)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct PulsationAverageFields: View {
    @Binding var average: PulsationAverage
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Ratio Front")
                    .frame(width: 100, alignment: .leading)
                Spacer()
                TextField("--", text: Binding(
                    get: { average.ratio1.map { String(format: "%.1f", $0) } ?? "" },
                    set: { newValue in
                        if let doubleValue = Double(newValue) {
                            average.ratio1 = doubleValue
                        } else if newValue.isEmpty {
                            average.ratio1 = nil
                        }
                    }
                ))
                .keyboardType(.decimalPad)
                .frame(width: 60)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Text("Ratio Rear")
                    .frame(width: 100, alignment: .leading)
                Spacer()
                TextField("--", text: Binding(
                    get: { average.ratio2.map { String(format: "%.1f", $0) } ?? "" },
                    set: { newValue in
                        if let doubleValue = Double(newValue) {
                            average.ratio2 = doubleValue
                        } else if newValue.isEmpty {
                            average.ratio2 = nil
                        }
                    }
                ))
                .keyboardType(.decimalPad)
                .frame(width: 60)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Text("Rate (ppm)")
                    .frame(width: 100, alignment: .leading)
                Spacer()
                TextField("--", text: Binding(
                    get: { average.rate.map { String(format: "%.0f", $0) } ?? "" },
                    set: { newValue in
                        if let doubleValue = Double(newValue) {
                            average.rate = doubleValue
                        } else if newValue.isEmpty {
                            average.rate = nil
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
}

struct VoltageChecksFields: View {
    @Binding var voltage: VoltageChecks
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("At Control")
                    .frame(width: 100, alignment: .leading)
                Spacer()
                TextField("--", text: Binding(
                    get: { voltage.atControl.map { String(format: "%.1f", $0) } ?? "" },
                    set: { newValue in
                        if let doubleValue = Double(newValue) {
                            voltage.atControl = doubleValue
                        } else if newValue.isEmpty {
                            voltage.atControl = nil
                        }
                    }
                ))
                .keyboardType(.decimalPad)
                .frame(width: 60)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Text("At Last")
                    .frame(width: 100, alignment: .leading)
                Spacer()
                TextField("--", text: Binding(
                    get: { voltage.atLast.map { String(format: "%.1f", $0) } ?? "" },
                    set: { newValue in
                        if let doubleValue = Double(newValue) {
                            voltage.atLast = doubleValue
                        } else if newValue.isEmpty {
                            voltage.atLast = nil
                        }
                    }
                ))
                .keyboardType(.decimalPad)
                .frame(width: 60)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Text("At Other")
                    .frame(width: 100, alignment: .leading)
                Spacer()
                TextField("--", text: Binding(
                    get: { voltage.atOther.map { String(format: "%.1f", $0) } ?? "" },
                    set: { newValue in
                        if let doubleValue = Double(newValue) {
                            voltage.atOther = doubleValue
                        } else if newValue.isEmpty {
                            voltage.atOther = nil
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
} 