import SwiftUI

struct InvoiceRowView: View {
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode
    let invoice: Invoice

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("#\(invoice.invoiceNumber)")
                    .font(.body.weight(.medium))
                Text(invoice.client?.name ?? "No client")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Due \(Formatters.mediumDate.string(from: invoice.dueDate))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(Formatters.currency(invoice.subtotal, code: currencyCode))
                    .font(.body.weight(.semibold))
                statusBadge
            }
        }
        .padding(.vertical, 2)
    }

    private var statusBadge: some View {
        let status = invoice.effectiveStatus
        return Label(status.label, systemImage: status.systemImage)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(status.color)
            .labelStyle(.titleAndIcon)
    }
}
