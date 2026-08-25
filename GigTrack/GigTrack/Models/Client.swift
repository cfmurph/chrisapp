import Foundation
import SwiftData

/// A billing contact / client that invoices are sent to.
@Model
final class Client {
    // CloudKit-backed SwiftData requires every non-optional attribute to have
    // a property-level default value, so every stored property below is
    // declared with one even though `init` always supplies a real value.
    var id: UUID = UUID()
    var name: String = ""
    var email: String = ""
    var phone: String = ""
    var address: String = ""
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \Invoice.client)
    var invoices: [Invoice]? = []

    init(
        name: String,
        email: String = "",
        phone: String = "",
        address: String = "",
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
        self.createdAt = createdAt
    }
}
