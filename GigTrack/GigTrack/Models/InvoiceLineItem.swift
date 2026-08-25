import Foundation
import SwiftData

@Model
final class InvoiceLineItem {
    // CloudKit-backed SwiftData requires every non-optional attribute to have
    // a property-level default value; relationships must stay optional.
    var id: UUID = UUID()
    var itemDescription: String = ""
    var quantity: Double = 1
    var unitPrice: Double = 0
    var sortOrder: Int = 0
    var invoice: Invoice?

    init(
        itemDescription: String = "",
        quantity: Double = 1,
        unitPrice: Double = 0,
        sortOrder: Int = 0,
        invoice: Invoice? = nil
    ) {
        self.id = UUID()
        self.itemDescription = itemDescription
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.sortOrder = sortOrder
        self.invoice = invoice
    }

    var total: Double { quantity * unitPrice }
}
