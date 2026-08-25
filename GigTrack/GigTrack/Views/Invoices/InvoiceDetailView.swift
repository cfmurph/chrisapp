import SwiftUI

struct InvoiceDetailView: View {
    @Bindable var invoice: Invoice
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode
    @AppStorage(AppStorageKeys.businessName) private var businessName = ""
    @AppStorage(AppStorageKeys.businessEmail) private var businessEmail = ""

    @State private var showingEdit = false
    @State private var shareItem: ShareItem?

    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("#\(invoice.invoiceNumber)").font(.title3.bold())
                        Text(invoice.client?.name ?? "No client assigned")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Label(invoice.effectiveStatus.label, systemImage: invoice.effectiveStatus.systemImage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(invoice.effectiveStatus.color)
                }

                LabeledContent("Issued", value: Formatters.mediumDate.string(from: invoice.issueDate))
                LabeledContent("Due", value: Formatters.mediumDate.string(from: invoice.dueDate))
                if let paidDate = invoice.paidDate {
                    LabeledContent("Paid", value: Formatters.mediumDate.string(from: paidDate))
                }
            }

            Section("Line Items") {
                ForEach(invoice.sortedLineItems) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.itemDescription.isEmpty ? "Item" : item.itemDescription)
                            Text("\(item.quantity.formatted()) x \(Formatters.currency(item.unitPrice, code: currencyCode))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(Formatters.currency(item.total, code: currencyCode))
                    }
                }
                HStack {
                    Text("Total").font(.body.weight(.semibold))
                    Spacer()
                    Text(Formatters.currency(invoice.subtotal, code: currencyCode)).font(.body.weight(.semibold))
                }
            }

            if !invoice.notes.isEmpty {
                Section("Notes") {
                    Text(invoice.notes)
                }
            }

            Section("Payment Status") {
                Picker("Status", selection: $invoice.status) {
                    ForEach(InvoiceStatus.allCases) { status in
                        Text(status.label).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: invoice.status) { _, newStatus in
                    if newStatus == .paid {
                        invoice.paidDate = invoice.paidDate ?? .now
                    } else {
                        invoice.paidDate = nil
                    }
                }
            }

            Section {
                Button {
                    let pdfData = InvoicePDFGenerator.makePDF(
                        for: invoice,
                        businessName: businessName,
                        businessEmail: businessEmail,
                        currencyCode: currencyCode
                    )
                    let url = InvoicePDFGenerator.writeTempFile(for: invoice, data: pdfData)
                    shareItem = ShareItem(url: url)
                    if invoice.status == .draft {
                        invoice.status = .sent
                    }
                } label: {
                    Label("Send / Share Invoice PDF", systemImage: "paperplane")
                }
            }
        }
        .navigationTitle("Invoice")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditInvoiceView(invoice: invoice)
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: item.urls)
        }
    }
}
