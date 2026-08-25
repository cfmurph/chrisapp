import Foundation
import SwiftData

@Model
final class Receipt {
    // CloudKit-backed SwiftData requires every non-optional attribute to have
    // a property-level default value, so every stored property below is
    // declared with one even though `init` always supplies a real value.
    var id: UUID = UUID()
    var date: Date = Date.now
    var vendor: String = ""
    var amount: Double = 0
    var category: String = ReceiptCategory.other.rawValue
    var notes: String = ""
    var createdAt: Date = Date.now

    @Attribute(.externalStorage)
    var imageData: Data?

    init(
        date: Date = .now,
        vendor: String = "",
        amount: Double = 0,
        category: String = ReceiptCategory.other.rawValue,
        notes: String = "",
        imageData: Data? = nil,
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.date = date
        self.vendor = vendor
        self.amount = amount
        self.category = category
        self.notes = notes
        self.imageData = imageData
        self.createdAt = createdAt
    }
}

enum ReceiptCategory: String, CaseIterable, Identifiable {
    case gear = "Gear & Equipment"
    case travel = "Travel"
    case lodging = "Lodging"
    case meals = "Meals"
    case venue = "Venue"
    case marketing = "Marketing"
    case supplies = "Supplies"
    case other = "Other"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .gear: return "guitars"
        case .travel: return "car"
        case .lodging: return "bed.double"
        case .meals: return "fork.knife"
        case .venue: return "building.2"
        case .marketing: return "megaphone"
        case .supplies: return "shippingbox"
        case .other: return "receipt"
        }
    }
}
