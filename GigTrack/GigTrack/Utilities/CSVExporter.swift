import Foundation

/// Builds CSV files for each data type so users can back up or import their
/// data into a spreadsheet / accounting tool. Plain-text CSV, not tied to
/// SwiftData or CloudKit in any way.
enum CSVExporter {
    // MARK: - Row builders

    static func receiptsCSV(_ receipts: [Receipt]) -> String {
        var rows: [[String]] = [["Date", "Vendor", "Category", "Amount", "Notes"]]
        for r in receipts.sorted(by: { $0.date < $1.date }) {
            rows.append([
                isoDate(r.date), r.vendor, r.category,
                currencyValue(r.amount), r.notes
            ])
        }
        return csv(from: rows)
    }

    static func invoicesCSV(_ invoices: [Invoice]) -> String {
        var rows: [[String]] = [["Invoice Number", "Client", "Issue Date", "Due Date", "Status", "Subtotal", "Paid Date", "Notes"]]
        for inv in invoices.sorted(by: { $0.issueDate < $1.issueDate }) {
            rows.append([
                inv.invoiceNumber,
                inv.client?.name ?? "",
                isoDate(inv.issueDate),
                isoDate(inv.dueDate),
                inv.effectiveStatus.label,
                currencyValue(inv.subtotal),
                inv.paidDate.map(isoDate) ?? "",
                inv.notes
            ])
        }
        return csv(from: rows)
    }

    static func invoiceLineItemsCSV(_ invoices: [Invoice]) -> String {
        var rows: [[String]] = [["Invoice Number", "Description", "Quantity", "Unit Price", "Line Total"]]
        for inv in invoices.sorted(by: { $0.issueDate < $1.issueDate }) {
            for item in inv.sortedLineItems {
                rows.append([
                    inv.invoiceNumber, item.itemDescription,
                    numberValue(item.quantity), currencyValue(item.unitPrice), currencyValue(item.total)
                ])
            }
        }
        return csv(from: rows)
    }

    static func timeEntriesCSV(_ entries: [TimeEntry]) -> String {
        var rows: [[String]] = [["Person", "Project", "Start", "End", "Hours", "Est. Earnings", "Notes"]]
        for e in entries.sorted(by: { $0.startTime < $1.startTime }) {
            rows.append([
                e.person?.name ?? "",
                e.project,
                isoDateTime(e.startTime),
                e.endTime.map(isoDateTime) ?? "(running)",
                numberValue(e.durationHours),
                currencyValue(e.earnings),
                e.notes
            ])
        }
        return csv(from: rows)
    }

    static func drivingTripsCSV(_ trips: [DrivingTrip]) -> String {
        var rows: [[String]] = [["Date", "Start Location", "End Location", "Purpose", "Miles", "Rate/Mile", "Cost", "Notes"]]
        for t in trips.sorted(by: { $0.date < $1.date }) {
            rows.append([
                isoDate(t.date), t.startLocation, t.endLocation, t.purpose,
                numberValue(t.miles), currencyValue(t.ratePerMile), currencyValue(t.cost), t.notes
            ])
        }
        return csv(from: rows)
    }

    // MARK: - File writing

    /// Writes CSV text to a temp file with the given name and returns its URL,
    /// ready to hand to a share sheet.
    static func writeTempFile(named name: String, csv: String) -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try? csv.data(using: .utf8)?.write(to: url, options: .atomic)
        return url
    }

    // MARK: - CSV formatting helpers

    private static func csv(from rows: [[String]]) -> String {
        rows.map { row in row.map(escapeField).joined(separator: ",") }.joined(separator: "\r\n") + "\r\n"
    }

    private static func escapeField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") || field.contains("\r") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }

    private static func isoDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter.string(from: date)
    }

    private static func isoDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter.string(from: date)
    }

    private static func currencyValue(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    private static func numberValue(_ value: Double) -> String {
        value == value.rounded() ? String(format: "%.0f", value) : String(format: "%.2f", value)
    }
}
