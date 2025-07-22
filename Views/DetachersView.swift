import SwiftUI

struct DetachersView: View {
    @ObservedObject var auditViewModel: AuditViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CardView(header: "Detacher Settings") {
                    VStack(spacing: 16) {
                        AuditStepperField(
                            label: "Cluster Removal Delay (s)",
                            value: Binding(
                                get: { auditViewModel.detacherSettings?.clusterRemovalDelay ?? 0 },
                                set: { 
                                    if auditViewModel.detacherSettings == nil {
                                        auditViewModel.detacherSettings = DetacherSettings()
                                    }
                                    auditViewModel.detacherSettings?.clusterRemovalDelay = $0 
                                }
                            ),
                            range: 0...20, step: 0.1
                        )
                        AuditStepperField(
                            label: "Blink Time Delay (s)",
                            value: Binding(
                                get: { auditViewModel.detacherSettings?.blinkTimeDelay ?? 0 },
                                set: { 
                                    if auditViewModel.detacherSettings == nil {
                                        auditViewModel.detacherSettings = DetacherSettings()
                                    }
                                    auditViewModel.detacherSettings?.blinkTimeDelay = $0 
                                }
                            ),
                            range: 0...20, step: 0.1
                        )
                        AuditStepperField(
                            label: "Detach Flow Setting",
                            value: Binding(
                                get: { auditViewModel.detacherSettings?.detachFlowSetting ?? 0 },
                                set: { 
                                    if auditViewModel.detacherSettings == nil {
                                        auditViewModel.detacherSettings = DetacherSettings()
                                    }
                                    auditViewModel.detacherSettings?.detachFlowSetting = $0 
                                }
                            ),
                            range: 0...20, step: 0.1
                        )
                        AuditStepperField(
                            label: "Let Down Delay (s)",
                            value: Binding(
                                get: { auditViewModel.detacherSettings?.letDownDelay ?? 0 },
                                set: { 
                                    if auditViewModel.detacherSettings == nil {
                                        auditViewModel.detacherSettings = DetacherSettings()
                                    }
                                    auditViewModel.detacherSettings?.letDownDelay = $0 
                                }
                            ),
                            range: 0...20, step: 0.1
                        )
                    }
                }
                CardView(header: "Notes") {
                    HStack(alignment: .top) {
                        TextEditor(text: Binding(
                            get: { auditViewModel.detacherSettings?.notes ?? "" },
                            set: { 
                                if auditViewModel.detacherSettings == nil {
                                    auditViewModel.detacherSettings = DetacherSettings()
                                }
                                auditViewModel.detacherSettings?.notes = $0 
                            }
                        ))
                        .frame(height: 80)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                        Button(action: { /* Speech-to-text placeholder */ }) {
                            Image(systemName: "mic.fill")
                                .font(.title2)
                                .padding(8)
                        }
                        .accessibilityLabel("Record Note")
                    }
                }
            }
            .padding()
        }
    }
}

struct AuditStepperField: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        HStack {
            Text(label)
                .frame(width: 180, alignment: .leading)
            Spacer()
            Stepper(value: $value, in: range, step: step) {
                Text(String(format: "%g", value))
                    .frame(width: 60, alignment: .trailing)
            }
        }
    }
} 