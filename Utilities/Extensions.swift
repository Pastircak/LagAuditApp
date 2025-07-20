import Foundation
import SwiftUI

extension DateFormatter {
    static let auditDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

extension Color {
    static let systemBackground = Color.white
    static let secondarySystemBackground = Color.gray.opacity(0.1)
    static let tertiarySystemBackground = Color.gray.opacity(0.05)
    static let systemGray = Color.gray
    static let systemGray2 = Color.gray.opacity(0.8)
    static let systemGray3 = Color.gray.opacity(0.6)
    static let systemGray4 = Color.gray.opacity(0.4)
    static let systemGray5 = Color.gray.opacity(0.2)
    static let systemGray6 = Color.gray.opacity(0.1)
}

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.systemBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    func sectionStyle() -> some View {
        self
            .padding()
            .background(Color.systemGray6)
            .cornerRadius(8)
    }
}

extension String {
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmptyOrWhitespace: Bool {
        self.trimmed.isEmpty
    }
}

extension Double {
    func formatted(to decimalPlaces: Int = 1) -> String {
        String(format: "%.\(decimalPlaces)f", self)
    }
}

extension Int {
    var formatted: String {
        String(self)
    }
} 