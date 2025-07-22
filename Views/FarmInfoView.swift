import SwiftUI

struct FarmInfoView: View {
    @ObservedObject var auditViewModel: AuditViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                dairyInfoCard
                contactInfoCard
                addressCard
                systemInfoCard
            }
            .padding()
        }
        .onAppear {
            // Initialize farmInfo if it doesn't exist
            if auditViewModel.farmInfo == nil {
                auditViewModel.farmInfo = FarmInfo()
            }
        }
    }
    
    private var dairyInfoCard: some View {
        CardView(header: "Dairy Info") {
            VStack {
                TextField("Dairy Name", text: Binding(
                    get: { auditViewModel.farmInfo?.dairyName ?? "" },
                    set: { auditViewModel.farmInfo?.dairyName = $0 }
                ))
                DatePicker("Date", selection: Binding(
                    get: { auditViewModel.farmInfo?.date ?? Date() },
                    set: { auditViewModel.farmInfo?.date = $0 }
                ), displayedComponents: .date)
                TextField("Prepared By", text: Binding(
                    get: { auditViewModel.farmInfo?.preparedBy ?? "" },
                    set: { auditViewModel.farmInfo?.preparedBy = $0 }
                ))
            }
        }
    }
    
    private var contactInfoCard: some View {
        CardView(header: "Contact Info") {
            VStack {
                TextField("Contact Name", text: Binding(
                    get: { auditViewModel.farmInfo?.contactName ?? "" },
                    set: { auditViewModel.farmInfo?.contactName = $0 }
                ))
                TextField("Phone", text: Binding(
                    get: { auditViewModel.farmInfo?.phone ?? "" },
                    set: { auditViewModel.farmInfo?.phone = $0 }
                ))
                TextField("Email", text: Binding(
                    get: { auditViewModel.farmInfo?.email ?? "" },
                    set: { auditViewModel.farmInfo?.email = $0 }
                ))
            }
        }
    }
    
    private var addressCard: some View {
        CardView(header: "Address") {
            VStack {
                TextField("Address", text: Binding(
                    get: { auditViewModel.farmInfo?.address ?? "" },
                    set: { auditViewModel.farmInfo?.address = $0 }
                ))
                TextField("City", text: Binding(
                    get: { auditViewModel.farmInfo?.city ?? "" },
                    set: { auditViewModel.farmInfo?.city = $0 }
                ))
                TextField("State", text: Binding(
                    get: { auditViewModel.farmInfo?.state ?? "" },
                    set: { auditViewModel.farmInfo?.state = $0 }
                ))
                TextField("ZIP", text: Binding(
                    get: { auditViewModel.farmInfo?.zip ?? "" },
                    set: { auditViewModel.farmInfo?.zip = $0 }
                ))
            }
        }
    }
    
    private var systemInfoCard: some View {
        CardView(header: "System Info") {
            VStack {
                basicInfoSection
                parlorConfigSection
                linerTypeSection
                hoseSizeSection
                systemTypeSection
                productionSection
                milkLineSection
                pumpSection
            }
        }
    }
    
    private var basicInfoSection: some View {
        HStack {
            TextField("# of Cows", text: Binding(
                get: { String(auditViewModel.farmInfo?.numberOfCows ?? 0) },
                set: { auditViewModel.farmInfo?.numberOfCows = Int16($0) ?? 0 }
            ))
            TextField("# of Stalls", text: Binding(
                get: { String(auditViewModel.farmInfo?.numberOfStalls ?? 0) },
                set: { auditViewModel.farmInfo?.numberOfStalls = Int16($0) ?? 0 }
            ))
        }
    }
    
    private var parlorConfigSection: some View {
        VStack(alignment: .leading) {
            Text("Parlor Configuration")
                .font(.headline)
            Picker("Parlor Config", selection: Binding(
                get: { auditViewModel.farmInfo?.parlorConfig ?? .parallel },
                set: { auditViewModel.farmInfo?.parlorConfig = $0 }
            )) {
                ForEach(ParlorType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var linerTypeSection: some View {
        VStack(alignment: .leading) {
            Text("Liner Type")
                .font(.headline)
            Picker("Liner Type", selection: Binding(
                get: { auditViewModel.farmInfo?.linerType ?? .classic },
                set: { auditViewModel.farmInfo?.linerType = $0 }
            )) {
                ForEach(LinerType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var hoseSizeSection: some View {
        VStack(alignment: .leading) {
            Text("Hose Size")
                .font(.headline)
            Picker("Hose Size", selection: Binding(
                get: { auditViewModel.farmInfo?.milkHoseID ?? .threeQuarters },
                set: { auditViewModel.farmInfo?.milkHoseID = $0 }
            )) {
                ForEach(HoseSize.allCases, id: \.self) { size in
                    Text(size.rawValue).tag(size)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var systemTypeSection: some View {
        VStack(alignment: .leading) {
            Text("System Type")
                .font(.headline)
            Picker("System Type", selection: Binding(
                get: { auditViewModel.farmInfo?.systemType ?? .highLine },
                set: { auditViewModel.farmInfo?.systemType = $0 }
            )) {
                ForEach(SystemType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var productionSection: some View {
        HStack {
            TextField("Production (lbs/day)", text: Binding(
                get: { String(auditViewModel.farmInfo?.milkProductionLbs ?? 0) },
                set: { auditViewModel.farmInfo?.milkProductionLbs = Double($0) ?? 0 }
            ))
            TextField("Milkings/day", text: Binding(
                get: { String(auditViewModel.farmInfo?.milkingFrequency ?? 0) },
                set: { auditViewModel.farmInfo?.milkingFrequency = Int8($0) ?? 0 }
            ))
        }
    }
    
    private var milkLineSection: some View {
        HStack {
            TextField("Milk Line Height (ft)", text: Binding(
                get: { String(auditViewModel.farmInfo?.milkLineHeight ?? 0) },
                set: { auditViewModel.farmInfo?.milkLineHeight = Double($0) ?? 0 }
            ))
            TextField("Milk Line Length (ft)", text: Binding(
                get: { String(auditViewModel.farmInfo?.milkLineLength ?? 0) },
                set: { auditViewModel.farmInfo?.milkLineLength = Double($0) ?? 0 }
            ))
        }
    }
    
    private var pumpSection: some View {
        HStack {
            TextField("Pump Capacity (GPM)", text: Binding(
                get: { String(auditViewModel.farmInfo?.pumpCapacity ?? 0) },
                set: { auditViewModel.farmInfo?.pumpCapacity = Double($0) ?? 0 }
            ))
            TextField("Pump Speed (RPM)", text: Binding(
                get: { String(auditViewModel.farmInfo?.pumpSpeed ?? 0) },
                set: { auditViewModel.farmInfo?.pumpSpeed = Double($0) ?? 0 }
            ))
        }
    }
}

// MARK: - Supporting Views

struct CardView<Content: View>: View {
    let header: String
    let content: Content
    
    init(header: String, @ViewBuilder content: () -> Content) {
        self.header = header
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(header)
                .font(.headline)
                .foregroundColor(.primary)
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
} 