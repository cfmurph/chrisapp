import Foundation
import SwiftData

/// A person who logs hours (musician, sound tech, roadie, etc.).
@Model
final class Person {
    var id: UUID
    var name: String
    var role: String
    var hourlyRate: Double
    var createdAt: Date

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
