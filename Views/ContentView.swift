import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager: AuditDataManager
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _dataManager = StateObject(wrappedValue: AuditDataManager(context: context))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome header
                    welcomeHeader
                    
                    // Quick statistics
                    if !dataManager.audits.isEmpty {
                        quickStatistics
                    }
                    
                    // Main actions
                    mainActions
                    
                    // Recent audits
                    if !dataManager.audits.isEmpty {
                        recentAudits
                    }
                }
                .padding()
            }
            .navigationTitle("Lag Audit")
            .refreshable {
                dataManager.loadData()
            }
        }
    }
    
    private var welcomeHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Welcome to Lag Audit")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your comprehensive milking system evaluation tool")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.systemGray6)
        .cornerRadius(12)
    }
    
    private var quickStatistics: some View {
        let stats = dataManager.getAuditStatistics()
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(title: "Total Audits", value: "\(stats.totalAudits)", color: Color.blue)
                StatCard(title: "Farms", value: "\(dataManager.farms.count)", color: Color.green)
                StatCard(title: "Issues", value: "\(stats.criticalIssues + stats.warningIssues)", color: Color.orange)
            }
        }
    }
    
    private var mainActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                NavigationLink(destination: StartAuditView()) {
                    ActionCard(
                        title: "New Audit",
                        subtitle: "Start a new milking system evaluation",
                        icon: "plus.circle.fill",
                        color: .blue
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: AuditHistoryView()) {
                    ActionCard(
                        title: "View History",
                        subtitle: "Browse past audits and results",
                        icon: "clock.fill",
                        color: .green
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: SettingsView()) {
                    ActionCard(
                        title: "Settings",
                        subtitle: "Manage farms and app settings",
                        icon: "gear",
                        color: .gray
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                if dataManager.farms.isEmpty {
                    Button(action: {
                        // This would open farm creation
                    }) {
                        ActionCard(
                            title: "Add Farm",
                            subtitle: "Create your first farm",
                            icon: "building.2",
                            color: .orange
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    ActionCard(
                        title: "Farm Management",
                        subtitle: "Manage your farms",
                        icon: "building.2",
                        color: .orange
                    )
                    .onTapGesture {
                        // Navigate to farm management
                    }
                }
            }
        }
    }
    
    private var recentAudits: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Audits")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink("View All", destination: AuditHistoryView())
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(Array(dataManager.audits.prefix(3)), id: \.id) { audit in
                    RecentAuditRow(audit: audit)
                        .onTapGesture {
                            // Navigate to audit detail
                        }
                }
            }
        }
    }
}

struct ActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.systemGray6)
        .cornerRadius(12)
    }
}

struct RecentAuditRow: View {
    let audit: Audit
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(audit.farmName ?? "Unknown Farm")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let date = audit.date {
                    Text(DateFormatter.auditDate.string(from: date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Status indicator
            if let entries = audit.entries?.allObjects as? [AuditEntry] {
                let hasCritical = entries.contains { $0.status == "Critical" }
                let hasWarnings = entries.contains { $0.status == "Low" || $0.status == "High" }
                
                let statusColor: Color = hasCritical ? .red : (hasWarnings ? .orange : .green)
                let statusIcon = hasCritical ? "exclamationmark.triangle.fill" : (hasWarnings ? "exclamationmark.triangle" : "checkmark.circle")
                
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.systemGray6)
        .cornerRadius(8)
    }
}
