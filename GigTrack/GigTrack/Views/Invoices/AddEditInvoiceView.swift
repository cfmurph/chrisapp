import SwiftUI
import SwiftData

private struct LineItemDraft: Identifiable {
    let id: UUID
    var description: String
    var quantity: Double
    var unitPrice: Double
    var existingItem: InvoiceLineItem?

    var total: Double { quantity * unitPrice }
}

struct AddEditInvoiceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode

    let invoice: Invoice?

    @Query(sort: \Client.name) private var clients: [Client]
    @Query private var allInvoices: [Invoice]

    @State private var invoiceNumber = ""
    @State private var selectedClient: Client?
    @State private var issueDate: Date = .now
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 14, to: .now) ?? .now
    @State private var status: InvoiceStatus = .draft
    @State private var notes = ""
    @State private var lineItems: [LineItemDraft] = []
    @State private var showingAddClient = false

    private var isEditing: Bool { invoice != nil }

    private var subtotal: Double {
        lineItems.reduce(0) { $0 + $1.total }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Invoice") {
                    TextField("Invoice Number", text: $invoiceNumber)
                    Picker("Client", selection: $selectedClient) {
                        Text("None").tag(Client?.none)
                        ForEach(clients) { client in
                            Text(client.name).tag(Client?.some(client))
                        }
                    }
                    Button {
                        showingAddClient = true
                    } label: {
                        Label("New Client", systemImage: "person.badge.plus")
                    }
                    DatePicker("Issue Date", selection: $issueDate, displayedComponents: .date)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    Picker("Status", selection: $status) {
                        ForEach(InvoiceStatus.allCases) { s in
                            Text(s.label).tag(s)
                        }
                    }
                }

                Section("Line Items") {
                    ForEach($lineItems) { $item in
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Description", text: $item.description)
                            HStack {
                                TextField("Qty", value: $item.quantity, format: .number)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 60)
                                Text("x")
                                    .foregroundStyle(.secondary)
                                TextField("Unit Price", value: $item.unitPrice, format: .currency(code: currencyCode))
                                    .keyboardType(.decimalPad)
                                Spacer()
                                Text(Formatters.currency(item.total, code: currencyCode))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { lineItems.remove(atOffsets: $0) }

                    Button {
                        lineItems.append(LineItemDraft(id: UUID(), description: "", quantity: 1, unitPrice: 0, existingItem: nil))
                    } label: {
                        Label("Add Line Item", systemImage: "plus.circle")
                    }

                    HStack {
                        Text("Subtotal").font(.body.weight(.semibold))
                        Spacer()
                        Text(Formatters.currency(subtotal, code: currencyCode)).font(.body.weight(.semibold))
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Invoice" : "New Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(invoiceNumber.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: populate)
            .sheet(isPresented: $showingAddClient) {
                AddEditClientView(client: nil)
            }
        }
    }

    private func populate() {
        guard lineItems.isEmpty else { return } // avoid re-populating after onAppear re-fires
        if let invoice {
            invoiceNumber = invoice.invoiceNumber
            selectedClient = invoice.client
            issueDate = invoice.issueDate
            dueDate = invoice.dueDate
            status = invoice.status
            notes = invoice.notes
            lineItems = invoice.sortedLineItems.map {
                LineItemDraft(id: $0.id, description: $0.itemDescription, quantity: $0.quantity, unitPrice: $0.unitPrice, existingItem: $0)
            }
        } else {
            invoiceNumber = Self.nextInvoiceNumber(existingCount: allInvoices.count)
            lineItems = [LineItemDraft(id: UUID(), description: "", quantity: 1, unitPrice: 0, existingItem: nil)]
        }
    }

    private static func nextInvoiceNumber(existingCount: Int) -> String {
        String(format: "INV-%03d", existingCount + 1)
    }

    private func save() {
        let targetInvoice: Invoice
        if let invoice {
            invoice.invoiceNumber = invoiceNumber
            invoice.client = selectedClient
            invoice.issueDate = issueDate
            invoice.dueDate = dueDate
            invoice.status = status
            invoice.notes = notes
            if status == .paid && invoice.paidDate == nil {
                invoice.paidDate = .now
            } else if status != .paid {
                invoice.paidDate = nil
            }
            targetInvoice = invoice
        } else {
            let newInvoice = Invoice(
                invoiceNumber: invoiceNumber,
                issueDate: issueDate,
                dueDate: dueDate,
                status: status,
                notes: notes,
                paidDate: status == .paid ? .now : nil,
                client: selectedClient
            )
            modelContext.insert(newInvoice)
            targetInvoice = newInvoice
        }

        reconcileLineItems(for: targetInvoice)
        dismiss()
    }

    private func reconcileLineItems(for invoice: Invoice) {
        let keptExisting = Set(lineItems.compactMap { $0.existingItem?.id })
        for existing in invoice.lineItems ?? [] where !keptExisting.contains(existing.id) {
            modelContext.delete(existing)
        }

        for (index, draft) in lineItems.enumerated() {
            if let existing = draft.existingItem {
                existing.itemDescription = draft.description
                existing.quantity = draft.quantity
                existing.unitPrice = draft.unitPrice
                existing.sortOrder = index
            } else {
                let newItem = InvoiceLineItem(
                    itemDescription: draft.description,
                    quantity: draft.quantity,
                    unitPrice: draft.unitPrice,
                    sortOrder: index,
                    invoice: invoice
                )
                modelContext.insert(newItem)
            }
        }
    }
}

#Preview {
    AddEditInvoiceView(invoice: nil)
        .modelContainer(for: [Invoice.self, Client.self, InvoiceLineItem.self], inMemory: true)
}
