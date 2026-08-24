import SwiftUI
import SwiftData

struct InvoicesListView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode
    @Query(sort: \Invoice.issueDate, order: .reverse) private var invoices: [Invoice]

    @State private var showingAddSheet = false
    @State private var invoiceToOpen: Invoice?

    private var totalPaid: Double {
        invoices.filter { $0.status == .paid }.reduce(0) { $0 + $1.subtotal }
    }

    private var totalOutstanding: Double {
        invoices.filter { $0.status != .paid }.reduce(0) { $0 + $1.subtotal }
    }

    var body: some View {
        List {
            if !invoices.isEmpty {
                StatCardRow(cards: [
                    ("Outstanding", Formatters.currency(totalOutstanding, code: currencyCode), .orange),
                    ("Paid", Formatters.currency(totalPaid, code: currencyCode), .green)
                ])
            }

            if invoices.isEmpty {
                EmptyStateView(
                    systemImage: "doc.text",
                    title: "No Invoices Yet",
                    message: "Create an invoice, send it to a client, and track when it gets paid."
                )
                .listRowSeparator(.hidden)
            } else {
                Section {
                    ForEach(invoices) { invoice in
                        Button {
                            invoiceToOpen = invoice
                        } label: {
                            InvoiceRowView(invoice: invoice)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteInvoices)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Invoices")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    ClientsListView()
                } label: {
                    Label("Clients", systemImage: "person.2")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("New Invoice", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditInvoiceView(invoice: nil)
        }
        .navigationDestination(item: $invoiceToOpen) { invoice in
            InvoiceDetailView(invoice: invoice)
        }
    }

    private func deleteInvoices(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(invoices[index])
        }
    }
}

#Preview {
    NavigationStack {
        InvoicesListView()
    }
    .modelContainer(for: [Invoice.self, Client.self, InvoiceLineItem.self], inMemory: true)
}
