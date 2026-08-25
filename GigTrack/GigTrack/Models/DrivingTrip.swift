import Foundation
import SwiftData

@Model
final class DrivingTrip {
    // CloudKit-backed SwiftData requires every non-optional attribute to have
    // a property-level default value, so every stored property below is
    // declared with one even though `init` always supplies a real value.
    var id: UUID = UUID()
    var date: Date = Date.now
    var startLocation: String = ""
    var endLocation: String = ""
    var miles: Double = 0
    var ratePerMile: Double = 0.67
    var purpose: String = ""
    var notes: String = ""
    var createdAt: Date = Date.now

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
