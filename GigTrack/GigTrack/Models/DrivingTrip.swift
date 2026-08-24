import Foundation
import SwiftData

@Model
final class DrivingTrip {
    var id: UUID
    var date: Date
    var startLocation: String
    var endLocation: String
    var miles: Double
    var ratePerMile: Double
    var purpose: String
    var notes: String
    var createdAt: Date

    init(
        date: Date = .now,
        startLocation: String = "",
        endLocation: String = "",
        miles: Double = 0,
        ratePerMile: Double = 0.67,
        purpose: String = "",
        notes: String = "",
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.date = date
        self.startLocation = startLocation
        self.endLocation = endLocation
        self.miles = miles
        self.ratePerMile = ratePerMile
        self.purpose = purpose
        self.notes = notes
        self.createdAt = createdAt
    }

    var cost: Double { miles * ratePerMile }
}
