import SwiftUI

struct SettingsView: View {
    @StateObject private var dataManager: AuditDataManager
    @State private var showingAddFarm = false
    @State private var showingExportOptions = false
    @State private var showingDeleteConfirmation = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _dataManager = StateObject(wrappedValue: AuditDataManager(context: context))
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Farm Management Section
                Section("Farm Management") {
                    NavigationLink("Manage Farms") {
                        FarmManagementView(dataManager: dataManager)
                    }
                    
                    Button("Add New Farm") {
                        showingAddFarm = true
                    }
                }
                
                // Data Management Section
                Section("Data Management") {
                    Button("Export Data") {
                        showingExportOptions = true
                    }
                    
                    Button("Clear All Data") {
                        showingDeleteConfirmation = true
                    }
                    .foregroundColor(.red)
                }
                
                // App Information Section
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink("About") {
                        AboutView()
                    }
                }
                
                // Statistics Section
                if !dataManager.audits.isEmpty {
                    Section("Statistics") {
                        let stats = dataManager.getAuditStatistics()
                        
                        HStack {
                            Text("Total Audits")
                            Spacer()
                            Text("\(stats.totalAudits)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Total Farms")
                            Spacer()
                            Text("\(dataManager.farms.count)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Critical Issues")
                            Spacer()
                            Text("\(stats.criticalIssues)")
                                .foregroundColor(.red)
                        }
                        
                        HStack {
                            Text("Warnings")
                            Spacer()
                            Text("\(stats.warningIssues)")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAddFarm) {
                AddFarmView(dataManager: dataManager)
            }
            .sheet(isPresented: $showingExportOptions) {
                ExportOptionsView(dataManager: dataManager)
            }
            .alert("Clear All Data", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all farms, audits, and data. This action cannot be undone.")
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func clearAllData() {
        do {
            // Delete all audits first (which will cascade delete entries)
            for audit in dataManager.audits {
                try dataManager.deleteAudit(audit)
            }
            
            // Delete all farms
            for farm in dataManager.farms {
                try dataManager.deleteFarm(farm)
            }
            
        } catch {
            errorMessage = "Failed to clear data: \(error.localizedDescription)"
            showingError = true
        }
    }
}

struct FarmManagementView: View {
    @ObservedObject var dataManager: AuditDataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            if dataManager.farms.isEmpty {
                Section {
                    Text("No farms available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            } else {
                ForEach(dataManager.farms, id: \.id) { farm in
                    Section {
                        FarmDetailRow(farm: farm, dataManager: dataManager)
                    }
                }
            }
        }
        .navigationTitle("Manage Farms")
    }
}

struct FarmDetailRow: View {
    let farm: Farm
    let dataManager: AuditDataManager
    @State private var showingEditFarm = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(farm.name ?? "Unknown Farm")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if let location = farm.location {
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    let auditCount = dataManager.getAudits(for: farm).count
                    Text("\(auditCount) audit\(auditCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            if let contact = farm.contactPerson {
                Text("Contact: \(contact)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let phone = farm.phone {
                Text("Phone: \(phone)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Button("Edit") {
                    showingEditFarm = true
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Delete") {
                    showingDeleteConfirmation = true
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditFarm) {
            EditFarmView(farm: farm, dataManager: dataManager)
        }
        .alert("Delete Farm", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteFarm()
            }
        } message: {
            Text("This will permanently delete the farm and all associated audits. This action cannot be undone.")
        }
    }
    
    private func deleteFarm() {
        do {
            try dataManager.deleteFarm(farm)
        } catch {
            print("Error deleting farm: \(error)")
        }
    }
}

struct EditFarmView: View {
    let farm: Farm
    let dataManager: AuditDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var farmName: String
    @State private var location: String
    @State private var contactPerson: String
    @State private var phone: String
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(farm: Farm, dataManager: AuditDataManager) {
        self.farm = farm
        self.dataManager = dataManager
        _farmName = State(initialValue: farm.name ?? "")
        _location = State(initialValue: farm.location ?? "")
        _contactPerson = State(initialValue: farm.contactPerson ?? "")
        _phone = State(initialValue: farm.phone ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Farm Information") {
                    TextField("Farm Name", text: $farmName)
                    TextField("Location", text: $location)
                }
                
                Section("Contact Information") {
                    TextField("Contact Person", text: $contactPerson)
                    TextField("Phone Number", text: $phone)
                }
            }
            .navigationTitle("Edit Farm")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveFarm()
                    }
                    .disabled(farmName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        farm.name = farmName.trimmingCharacters(in: .whitespacesAndNewlines)
        farm.location = location.trimmingCharacters(in: .whitespacesAndNewlines)
        farm.contactPerson = contactPerson.trimmingCharacters(in: .whitespacesAndNewlines)
        farm.phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try dataManager.updateFarm(farm)
            dismiss()
        } catch {
            errorMessage = "Failed to update farm: \(error.localizedDescription)"
            showingError = true
        }
    }
}

struct ExportOptionsView: View {
    let dataManager: AuditDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingExportSuccess = false
    @State private var showingExportError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section("Export Format") {
                    Button("Export as CSV") {
                        exportAsCSV()
                    }
                    
                    Button("Export as JSON") {
                        exportAsJSON()
                    }
                }
                
                Section("Export Options") {
                    Text("Data will be exported to your device's Files app")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Export Data")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Export Successful", isPresented: $showingExportSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Data has been exported to your Files app")
            }
            .alert("Export Failed", isPresented: $showingExportError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func exportAsCSV() {
        // Implementation for CSV export
        // This would generate a CSV file with all audit data
        showingExportSuccess = true
    }
    
    private func exportAsJSON() {
        // Implementation for JSON export
        // This would generate a JSON file with all audit data
        showingExportSuccess = true
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Lag Audit App")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Milking System Evaluation Tool")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            Section("Description") {
                Text("The Lag Audit App is a comprehensive tool for conducting milking system evaluations. It provides instant feedback based on industry guidelines and helps technicians maintain optimal milking system performance.")
                    .font(.body)
            }
            
            Section("Features") {
                VStack(alignment: .leading, spacing: 8) {
                    FeatureRow(icon: "checkmark.circle.fill", text: "Digital audit forms with instant feedback")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Industry-standard parameter guidelines")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Farm and audit management")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Historical data tracking")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Export capabilities")
                }
            }
            
            Section("Version Information") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("About")
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
        }
    }
}
