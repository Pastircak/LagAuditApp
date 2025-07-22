import SwiftUI

struct RecommendationsView: View {
    @ObservedObject var auditViewModel: AuditViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("Recommendations")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: addRecommendation) {
                        Label("Add", systemImage: "plus.circle")
                    }
                }
                ForEach(auditViewModel.recommendations.indices, id: \.self) { idx in
                    RecommendationRow(
                        model: $auditViewModel.recommendations[idx],
                        onDelete: { removeRecommendation(at: idx) },
                        showDelete: auditViewModel.recommendations.count > 1
                    )
                }
            }
            .padding()
        }
        .onAppear {
            // Initialize recommendations if not already present
            if auditViewModel.recommendations.isEmpty {
                auditViewModel.recommendations = [Recommendation(index: 1, text: "")]
            }
        }
    }
    
    private func addRecommendation() {
        let newIndex = Int8(auditViewModel.recommendations.count + 1)
        auditViewModel.recommendations.append(Recommendation(index: newIndex, text: ""))
    }
    
    private func removeRecommendation(at idx: Int) {
        auditViewModel.recommendations.remove(at: idx)
        // Update indices
        for i in 0..<auditViewModel.recommendations.count {
            auditViewModel.recommendations[i].index = Int8(i + 1)
        }
    }
}

struct RecommendationRow: View {
    @Binding var model: Recommendation
    var onDelete: () -> Void
    var showDelete: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(model.index).")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 30, alignment: .leading)
            
            TextEditor(text: Binding(
                get: { model.text },
                set: { model.text = $0 }
            ))
            .frame(height: 60)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
            
            if showDelete {
                Button(action: onDelete) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
                .accessibilityLabel("Remove Recommendation")
            }
        }
        .padding(.vertical, 4)
    }
} 