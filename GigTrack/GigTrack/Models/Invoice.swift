import Foundation
import SwiftData

@Model
final class Invoice {
    var id: UUID
    var invoiceNumber: String
    var issueDate: Date
    var dueDate: Date
    var statusRawValue: String
    var notes: String
    var paidDate: Date?
    var client: Client?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \InvoiceLineItem.invoice)
    var lineItems: [InvoiceLineItem]? = []

    init(
        invoiceNumber: String,
        issueDate: Date = .now,
        dueDate: Date = Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now,
        status: InvoiceStatus = .draft,
        notes: String = "",
        paidDate: Date? = nil,
        client: Client? = nil,
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.invoiceNumber = invoiceNumber
        self.issueDate = issueDate
        self.dueDate = dueDate
        self.statusRawValue = status.rawValue
        self.notes = notes
        self.paidDate = paidDate
        self.client = client
        self.createdAt = createdAt
    }

    var status: InvoiceStatus {
        get { InvoiceStatus(rawValue: statusRawValue) ?? .draft }
        set { statusRawValue = newValue.rawValue }
    }

    /// Status accounting for the due date: a `.sent` invoice past its due date reads as overdue.
    var effectiveStatus: InvoiceStatus {
        if status == .sent && dueDate < Calendar.current.startOfDay(for: .now) {
            return .overdue
        }
        return status
    }

    var subtotal: Double {
        (lineItems ?? []).reduce(0) { $0 + $1.total }
    }

    var sortedLineItems: [InvoiceLineItem] {
        (lineItems ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var isPaid: Bool { status == .paid }
}
