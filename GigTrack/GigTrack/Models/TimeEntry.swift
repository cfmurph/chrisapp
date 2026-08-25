import Foundation
import SwiftData

/// A single logged block of work time, optionally still running (endTime == nil).
@Model
final class TimeEntry {
    // CloudKit-backed SwiftData requires every non-optional attribute to have
    // a property-level default value; relationships must stay optional.
    var id: UUID = UUID()
    var project: String = ""
    var startTime: Date = Date.now
    var endTime: Date?
    var notes: String = ""
    var person: Person?

    init(
        project: String = "",
        startTime: Date = .now,
        endTime: Date? = nil,
        notes: String = "",
        person: Person? = nil
    ) {
        self.id = UUID()
        self.project = project
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
        self.person = person
    }

    /// True while the timer for this entry has not been stopped yet.
    var isRunning: Bool { endTime == nil }

    /// Duration in seconds, computed against "now" if still running.
    var duration: TimeInterval {
        max(0, (endTime ?? .now).timeIntervalSince(startTime))
    }

    var durationHours: Double { duration / 3600 }

    var earnings: Double {
        durationHours * (person?.hourlyRate ?? 0)
    }
}
