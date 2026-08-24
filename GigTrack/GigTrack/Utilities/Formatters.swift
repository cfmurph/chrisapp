import Foundation

enum Formatters {
    static func currency(_ value: Double, code: String) -> String {
        value.formatted(.currency(code: code))
    }

    static let mediumDate: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()

    static let mediumDateTime: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    static let shortTime: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        return df
    }()

    /// Formats seconds as "1h 24m 03s" (or "24m 03s" / "3s" when shorter).
    static func duration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds.rounded())
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%dh %02dm %02ds", h, m, s)
        } else if m > 0 {
            return String(format: "%dm %02ds", m, s)
        } else {
            return String(format: "%ds", s)
        }
    }

    /// Formats hours as a decimal, e.g. "2.25 hrs".
    static func hours(_ seconds: TimeInterval) -> String {
        let hrs = seconds / 3600
        return String(format: "%.2f hrs", hrs)
    }
}
