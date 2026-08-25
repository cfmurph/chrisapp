import Foundation
import SwiftData

/// A person who logs hours (musician, sound tech, roadie, etc.).
@Model
final class Person {
    // CloudKit-backed SwiftData requires every non-optional attribute to have
    // a property-level default value, so every stored property below is
    // declared with one even though `init` always supplies a real value.
    var id: UUID = UUID()
    var name: String = ""
    var role: String = ""
    var hourlyRate: Double = 0
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \TimeEntry.person)
    var timeEntries: [TimeEntry]? = []

    init(
        name: String,
        role: String = "",
        hourlyRate: Double = 0,
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.hourlyRate = hourlyRate
        self.createdAt = createdAt
    }
}
