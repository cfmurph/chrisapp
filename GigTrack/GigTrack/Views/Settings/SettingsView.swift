import SwiftUI
import SwiftData
import CloudKit

struct SettingsView: View {
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode
    @AppStorage(AppStorageKeys.defaultMileageRate) private var defaultMileageRate = AppStorageKeys.defaultMileageRateValue
    @AppStorage(AppStorageKeys.businessName) private var businessName = ""
    @AppStorage(AppStorageKeys.businessEmail) private var businessEmail = ""

    @Query private var receipts: [Receipt]
    @Query private var invoices: [Invoice]
    @Query private var timeEntries: [TimeEntry]
    @Query private var trips: [DrivingTrip]

    @State private var shareItem: ShareItem?
    @State private var cloudStatusMessage = "Checking iCloud status…"
    @State private var cloudStatusIcon = "icloud"
    @State private var cloudStatusColor: Color = .secondary

    private let commonCurrencyCodes = ["USD", "EUR", "GBP", "CAD", "AUD", "JPY", "MXN"]

    var body: some View {
        Form {
            Section("Business Info") {
                TextField("Business / Artist Name", text: $businessName)
                TextField("Business Email", text: $businessEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                Text("Shown at the top of shared invoice PDFs.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Currency") {
                Picker("Currency", selection: $currencyCode) {
                    ForEach(commonCurrencyCodes, id: \.self) { code in
                        Text(code).tag(code)
                    }
                    if !commonCurrencyCodes.contains(currencyCode) {
                        Text(currencyCode).tag(currencyCode)
                    }
                }
            }

            Section("Driving") {
                HStack {
                    Text("Default Mileage Rate")
                    Spacer()
                    TextField("Rate", value: $defaultMileageRate, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
                Text("Used to pre-fill the rate per mile for new trips. You can still override it per trip.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Manage") {
                NavigationLink {
                    PeopleListView()
                } label: {
                    Label("People", systemImage: "person.2")
                }
                NavigationLink {
                    ClientsListView()
                } label: {
                    Label("Clients", systemImage: "briefcase")
                }
            }

            Section {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: cloudStatusIcon)
                        .foregroundStyle(cloudStatusColor)
                        .font(.body)
                        .frame(width: 22)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cloudStatusMessage)
                        Text("Receipts, invoices, hours, and trips sync privately to your own iCloud account across your devices — nobody else can see them.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("iCloud Sync")
            }
            .task { await refreshCloudStatus() }

            Section {
                Button { export(exportReceipts) } label: {
                    Label("Export Receipts (CSV)", systemImage: "square.and.arrow.up")
                }
                Button { export(exportInvoices) } label: {
                    Label("Export Invoices (CSV)", systemImage: "square.and.arrow.up")
                }
                Button { export(exportTimeEntries) } label: {
                    Label("Export Time Entries (CSV)", systemImage: "square.and.arrow.up")
                }
                Button { export(exportTrips) } label: {
                    Label("Export Driving Trips (CSV)", systemImage: "square.and.arrow.up")
                }
                Button { export(exportEverything) } label: {
                    Label("Export Everything (CSV)", systemImage: "tray.and.arrow.up")
                }
            } header: {
                Text("Export Data")
            } footer: {
                Text("Exports plain CSV files you can open in Numbers, Excel, Google Sheets, or import into accounting software.")
            }

            Section {
                Text("GigTrack — Receipts, invoices, timesheets, and driving costs for people in the music industry.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: item.urls)
        }
    }

    // MARK: - iCloud status

    private func refreshCloudStatus() async {
        do {
            let status = try await CKContainer.default().accountStatus()
            switch status {
            case .available:
                cloudStatusMessage = "Signed in — syncing via iCloud"
                cloudStatusIcon = "checkmark.icloud"
                cloudStatusColor = .green
            case .noAccount:
                cloudStatusMessage = "Not signed into iCloud — data stays on this device only"
                cloudStatusIcon = "exclamationmark.icloud"
                cloudStatusColor = .orange
            case .restricted:
                cloudStatusMessage = "iCloud is restricted on this device — data stays local only"
                cloudStatusIcon = "exclamationmark.icloud"
                cloudStatusColor = .orange
            case .temporarilyUnavailable:
                cloudStatusMessage = "iCloud is temporarily unavailable"
                cloudStatusIcon = "exclamationmark.icloud"
                cloudStatusColor = .orange
            case .couldNotDetermine:
                cloudStatusMessage = "Couldn't determine iCloud status"
                cloudStatusIcon = "questionmark.circle"
                cloudStatusColor = .secondary
            @unknown default:
                cloudStatusMessage = "Unknown iCloud status"
                cloudStatusIcon = "questionmark.circle"
                cloudStatusColor = .secondary
            }
        } catch {
            cloudStatusMessage = "iCloud sync isn't set up for this build — data stays on this device only"
            cloudStatusIcon = "icloud.slash"
            cloudStatusColor = .secondary
        }
    }

    // MARK: - CSV export

    private func export(_ makeItem: () -> ShareItem) {
        shareItem = makeItem()
    }

    private func exportReceipts() -> ShareItem {
        let url = CSVExporter.writeTempFile(named: "Receipts.csv", csv: CSVExporter.receiptsCSV(receipts))
        return ShareItem(url: url)
    }

    private func exportInvoices() -> ShareItem {
        let urls = [
            CSVExporter.writeTempFile(named: "Invoices.csv", csv: CSVExporter.invoicesCSV(invoices)),
            CSVExporter.writeTempFile(named: "Invoice Line Items.csv", csv: CSVExporter.invoiceLineItemsCSV(invoices))
        ]
        return ShareItem(urls: urls)
    }

    private func exportTimeEntries() -> ShareItem {
        let url = CSVExporter.writeTempFile(named: "Time Entries.csv", csv: CSVExporter.timeEntriesCSV(timeEntries))
        return ShareItem(url: url)
    }

    private func exportTrips() -> ShareItem {
        let url = CSVExporter.writeTempFile(named: "Driving Trips.csv", csv: CSVExporter.drivingTripsCSV(trips))
        return ShareItem(url: url)
    }

    private func exportEverything() -> ShareItem {
        let urls = [
            CSVExporter.writeTempFile(named: "Receipts.csv", csv: CSVExporter.receiptsCSV(receipts)),
            CSVExporter.writeTempFile(named: "Invoices.csv", csv: CSVExporter.invoicesCSV(invoices)),
            CSVExporter.writeTempFile(named: "Invoice Line Items.csv", csv: CSVExporter.invoiceLineItemsCSV(invoices)),
            CSVExporter.writeTempFile(named: "Time Entries.csv", csv: CSVExporter.timeEntriesCSV(timeEntries)),
            CSVExporter.writeTempFile(named: "Driving Trips.csv", csv: CSVExporter.drivingTripsCSV(trips))
        ]
        return ShareItem(urls: urls)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [Receipt.self, Invoice.self, InvoiceLineItem.self, Client.self, TimeEntry.self, Person.self, DrivingTrip.self], inMemory: true)
}
