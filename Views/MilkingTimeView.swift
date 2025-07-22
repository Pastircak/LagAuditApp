import SwiftUI
import Foundation

struct MilkingTimeView: View {
    @ObservedObject var auditViewModel: AuditViewModel
    
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
                    ForEach(auditViewModel.milkingTimeRows.indices, id: \.self) { idx in
                        CowCardView(
                            cow: Binding(
                                get: { auditViewModel.milkingTimeRows[idx] },
                                set: { auditViewModel.milkingTimeRows[idx] = $0 }
                            ),
                            onRemove: { removeCow(at: idx) },
                            showRemove: auditViewModel.milkingTimeRows.count > 1
                        )
                    }
                }
                .padding(.vertical)
            }
        }
        .padding()
    }
    
    private func addCow() {
        let nextPosition = (auditViewModel.milkingTimeRows.last?.position ?? 0) + 1
        auditViewModel.milkingTimeRows.append(MilkingTimeRow(position: nextPosition))
    }
    
    private func removeCow(at idx: Int) {
        auditViewModel.milkingTimeRows.remove(at: idx)
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
        .background(Color(.systemBackground))
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
                Text("\(String(format: "%g", value ?? range.lowerBound)) \(unit)")
                    .frame(width: 80, alignment: .trailing)
            }
        }
        .onAppear {
            if let val = value {
                textValue = String(format: "%g", val)
            }
        }
    }
} 