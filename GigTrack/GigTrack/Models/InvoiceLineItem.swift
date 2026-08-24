import Foundation
import SwiftData

@Model
final class InvoiceLineItem {
    var id: UUID
    var itemDescription: String
    var quantity: Double
    var unitPrice: Double
    var sortOrder: Int
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
