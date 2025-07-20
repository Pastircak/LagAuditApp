import SwiftUI

struct FarmSelectionView: View {
    @Binding var selectedFarm: Farm?
    @ObservedObject var dataManager: AuditDataManager
    @State private var showingAddFarm = false
    @State private var newFarmName = ""
    @State private var newFarmLocation = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Farm")
                .font(.title2)
                .fontWeight(.semibold)
            
            if dataManager.farms.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "building.2")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No farms available")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Add your first farm to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Add Farm") {
                        showingAddFarm = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(dataManager.farms) { farm in
                            FarmRowView(
                                farm: farm,
                                isSelected: selectedFarm?.id == farm.id
                            ) {
                                selectedFarm = farm
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button("Add New Farm") {
                    showingAddFarm = true
                }
                .buttonStyle(.bordered)
            }
        }
        .sheet(isPresented: $showingAddFarm) {
            AddFarmView(dataManager: dataManager)
        }
    }
}

struct FarmRowView: View {
    let farm: Farm
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(farm.name ?? "Unknown Farm")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let location = farm.location, !location.isEmpty {
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.systemBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.systemGray4, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddFarmView: View {
    @ObservedObject var dataManager: AuditDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var farmName = ""
    @State private var farmLocation = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Farm Information") {
                    TextField("Farm Name", text: $farmName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Location (Optional)", text: $farmLocation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section {
                    Button("Save Farm") {
                        saveFarm()
                    }
                    .disabled(farmName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Add Farm")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveFarm() {
        let trimmedName = farmName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = farmLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try dataManager.createFarm(
                name: trimmedName, 
                location: trimmedLocation.isEmpty ? "" : trimmedLocation,
                contactPerson: "",
                phone: ""
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

#Preview {
    FarmSelectionView(
        selectedFarm: .constant(nil),
        dataManager: AuditDataManager(context: PersistenceController.preview.container.viewContext)
    )
} 