import Foundation
import SwiftUI

enum InvoiceStatus: String, Codable, CaseIterable, Identifiable {
    case draft
    case sent
    case paid
    case overdue

    var id: String { rawValue }

    var label: String {
        switch self {
        case .draft: return "Draft"
        case .sent: return "Sent"
        case .paid: return "Paid"
        case .overdue: return "Overdue"
        }
    }

    var color: Color {
        switch self {
        case .draft: return .gray
        case .sent: return .blue
        case .paid: return .green
        case .overdue: return .red
        }
    }

    var systemImage: String {
        switch self {
        case .draft: return "pencil.circle"
        case .sent: return "paperplane.circle"
        case .paid: return "checkmark.circle.fill"
        case .overdue: return "exclamationmark.circle.fill"
        }
    }
}
