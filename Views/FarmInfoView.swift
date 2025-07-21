import SwiftUI

struct FarmInfoView: View {
    @State private var dairyName: String = ""
    @State private var date: Date = Date()
    @State private var preparedBy: String = "Current Tech" // Replace with signed-in user
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var zip: String = ""
    @State private var contactName: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var numberOfCows: String = ""
    @State private var numberOfStalls: String = ""
    @State private var milkingFrequency: String = ""
    @State private var parlorConfig: ParlorType = .parallel
    @State private var parlorOther: String = ""
    @State private var linerType: LinerType = .classic
    @State private var linerOther: String = ""
    @State private var milkHoseID: HoseSize = .fiveEighths
    @State private var milkProductionLbs: String = ""
    @State private var scc: String = ""
    @State private var systemType: SystemType = .highLine
    @State private var systemOther: String = ""
    @State private var milkLineIDs: [String] = [""]
    @State private var milkLineSlope: String = ""
    @State private var vacuumPumpHP: String = ""
    @State private var hasVFD: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Dairy Info Card
                CardView(header: "Dairy Info") {
                    VStack {
                        TextField("Dairy Name", text: $dairyName)
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        TextField("Prepared By", text: $preparedBy)
                    }
                }
                // Contact Info Card
                CardView(header: "Contact Info") {
                    VStack {
                        TextField("Contact Name", text: $contactName)
                        TextField("Phone", text: $phone)
                        TextField("Email", text: $email)
                    }
                }
                // Address Card
                CardView(header: "Address") {
                    VStack {
                        TextField("Address", text: $address)
                        TextField("City", text: $city)
                        TextField("State", text: $state)
                        TextField("ZIP", text: $zip)
                    }
                }
                // System Card
                CardView(header: "System Info") {
                    VStack {
                        HStack {
                            TextField("# of Cows", text: $numberOfCows)
                            TextField("# of Stalls", text: $numberOfStalls)
                            TextField("Milking Frequency", text: $milkingFrequency)
                        }
                        // Parlor Config
                        VStack(alignment: .leading) {
                            Text("Parlor Config")
                            Picker("Parlor Config", selection: $parlorConfig) {
                                ForEach(ParlorType.allCases, id: \ .self) { type in
                                    Text(type.rawValue.capitalized).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            if parlorConfig == .other {
                                TextField("Other Parlor Type", text: $parlorOther)
                            }
                        }
                        // Liner Type
                        VStack(alignment: .leading) {
                            Text("Liner Type")
                            Picker("Liner Type", selection: $linerType) {
                                ForEach(LinerType.allCases, id: \ .self) { type in
                                    Text(type.rawValue.capitalized).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            if linerType == .other {
                                TextField("Other Liner Type", text: $linerOther)
                            }
                        }
                        // Hose Size
                        VStack(alignment: .leading) {
                            Text("Milk Hose ID")
                            Picker("Milk Hose ID", selection: $milkHoseID) {
                                ForEach(HoseSize.allCases, id: \ .self) { size in
                                    Text(size.rawValue).tag(size)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        // System Type
                        VStack(alignment: .leading) {
                            Text("System Type")
                            Picker("System Type", selection: $systemType) {
                                ForEach(SystemType.allCases, id: \ .self) { type in
                                    Text(type.rawValue.capitalized).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            if systemType == .other {
                                TextField("Other System Type", text: $systemOther)
                            }
                        }
                        TextField("Milk Production (lbs)", text: $milkProductionLbs)
                        TextField("SCC", text: $scc)
                        // Dynamic Milk Line IDs
                        VStack(alignment: .leading) {
                            Text("Milk Line IDs")
                            ForEach(milkLineIDs.indices, id: \ .self) { idx in
                                HStack {
                                    TextField("Line ID", text: $milkLineIDs[idx])
                                    if milkLineIDs.count > 1 {
                                        Button(action: { milkLineIDs.remove(at: idx) }) {
                                            Image(systemName: "minus.circle.fill")
                                        }
                                    }
                                }
                            }
                            Button(action: { milkLineIDs.append("") }) {
                                Label("Add Line ID", systemImage: "plus.circle")
                            }
                        }
                        TextField("Milk Line Slope (%)", text: $milkLineSlope)
                        TextField("Vacuum Pump HP", text: $vacuumPumpHP)
                        Toggle("Has VFD", isOn: $hasVFD)
                    }
                }
            }
            .padding()
        }
    }
}

struct CardView<Content: View>: View {
    let header: String
    let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(header)
                .font(.headline)
                .padding(.bottom, 4)
            content()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
} 