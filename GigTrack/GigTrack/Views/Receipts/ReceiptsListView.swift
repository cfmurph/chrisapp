import SwiftUI
import SwiftData

struct ReceiptsListView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode
    @Query(sort: \Receipt.date, order: .reverse) private var receipts: [Receipt]

    @State private var showingAddSheet = false
    @State private var receiptToEdit: Receipt?

    private var totalThisMonth: Double {
        let calendar = Calendar.current
        let now = Date()
        return receipts
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    private var totalAllTime: Double {
        receipts.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        List {
            if !receipts.isEmpty {
                StatCardRow(cards: [
                    ("This Month", Formatters.currency(totalThisMonth, code: currencyCode), .accentColor),
                    ("All Time", Formatters.currency(totalAllTime, code: currencyCode), .secondary)
                ])
            }

            if receipts.isEmpty {
                EmptyStateView(
                    systemImage: "receipt",
                    title: "No Receipts Yet",
                    message: "Tap + to snap or upload a receipt photo and track your expenses."
                )
                .listRowSeparator(.hidden)
            } else {
                Section {
                    ForEach(receipts) { receipt in
                        Button {
                            receiptToEdit = receipt
                        } label: {
                            ReceiptRowView(receipt: receipt)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteReceipts)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Receipts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Receipt", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditReceiptView(receipt: nil)
        }
        .sheet(item: $receiptToEdit) { receipt in
            AddEditReceiptView(receipt: receipt)
        }
    }

    private func deleteReceipts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(receipts[index])
        }
    }
}

#Preview {
    NavigationStack {
        ReceiptsListView()
    }
    .modelContainer(for: [Receipt.self], inMemory: true)
}
