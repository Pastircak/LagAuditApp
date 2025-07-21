import SwiftUI

struct RecommendationsView: View {
    @State private var recommendations: [RecommendationRowModel] = [RecommendationRowModel()]
    
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
                ForEach(recommendations.indices, id: \ .self) { idx in
                    RecommendationRow(
                        model: $recommendations[idx],
                        onDelete: { removeRecommendation(at: idx) },
                        showDelete: recommendations.count > 1
                    )
                }
            }
            .padding()
        }
    }
    
    private func addRecommendation() {
        recommendations.append(RecommendationRowModel())
    }
    private func removeRecommendation(at idx: Int) {
        recommendations.remove(at: idx)
    }
}

struct RecommendationRowModel: Identifiable {
    var id = UUID()
    var isChecked: Bool = false
    var text: String = ""
}

struct RecommendationRow: View {
    @Binding var model: RecommendationRowModel
    var onDelete: () -> Void
    var showDelete: Bool
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button(action: { model.isChecked.toggle() }) {
                Image(systemName: model.isChecked ? "checkmark.square.fill" : "square")
                    .foregroundColor(model.isChecked ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            TextEditor(text: $model.text)
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