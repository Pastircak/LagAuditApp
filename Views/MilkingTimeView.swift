import SwiftUI
import Foundation

struct MilkingTimeView: View {
    @State private var cows: [MilkingTimeRow] = (1...10).map { MilkingTimeRow(position: Int16($0)) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Milking Time Tests")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: addCow) {
                    Label("Add Cow", systemImage: "plus.circle")
                }
                .accessibilityLabel("Add Cow")
            }
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(cows.indices, id: \ .self) { idx in
                        CowCardView(cow: $cows[idx], onRemove: { removeCow(at: idx) }, showRemove: cows.count > 1)
                    }
                }
                .padding(.vertical)
            }
        }
        .padding()
    }
    
    private func addCow() {
        let nextPosition = (cows.last?.position ?? 0) + 1
        cows.append(MilkingTimeRow(position: nextPosition))
    }
    
    private func removeCow(at idx: Int) {
        cows.remove(at: idx)
    }
}

struct CowCardView: View {
    @Binding var cow: MilkingTimeRow
    var onRemove: () -> Void
    var showRemove: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Cow \(cow.position)")
                    .font(.headline)
                Spacer()
                if showRemove {
                    Button(action: onRemove) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                    .accessibilityLabel("Remove Cow")
                }
            }
            MetricInputStepper(label: "Avg Vacuum", value: $cow.avgVac, range: 0...30, step: 0.1, unit: "in Hg")
            MetricInputStepper(label: "Max Vacuum", value: $cow.maxVac, range: 0...30, step: 0.1, unit: "in Hg")
            MetricInputStepper(label: "Min Vacuum", value: $cow.minVac, range: 0...30, step: 0.1, unit: "in Hg")
            MetricInputStepper(label: "Fluctuation", value: $cow.fluctuation, range: 0...10, step: 0.1, unit: "in Hg")
            MetricInputStepper(label: "Flow Rate", value: $cow.flowRate, range: 0...20, step: 0.1, unit: "L/min")
            MetricInputStepper(label: "Strip Yield", value: $cow.stripYield, range: 0...10, step: 0.1, unit: "L")
            MetricInputStepper(label: "Stimulation Time", value: $cow.stimulationTime, range: 0...300, step: 1, unit: "s")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct MetricInputStepper: View {
    let label: String
    @Binding var value: Double?
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    
    @State private var textValue: String = ""
    
    var body: some View {
        HStack {
            Text(label)
                .frame(width: 130, alignment: .leading)
            Spacer()
            Stepper(value: Binding(
                get: { value ?? range.lowerBound },
                set: { newValue in
                    value = newValue
                    textValue = String(format: "%g", newValue)
                }
            ), in: range, step: step) {
                EmptyView()
            }
            .labelsHidden()
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
                        if d >= range.lowerBound && d <= range.upperBound {
                            value = d
                        }
                    }
                }
            ))
            .keyboardType(.numberPad)
            .frame(width: 60)
            .multilineTextAlignment(.trailing)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            Text(unit)
                .foregroundColor(.secondary)
        }
    }
} 