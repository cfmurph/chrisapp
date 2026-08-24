import SwiftUI

struct SettingsView: View {
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode
    @AppStorage(AppStorageKeys.defaultMileageRate) private var defaultMileageRate = AppStorageKeys.defaultMileageRateValue
    @AppStorage(AppStorageKeys.businessName) private var businessName = ""
    @AppStorage(AppStorageKeys.businessEmail) private var businessEmail = ""

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
                Text("GigTrack — Receipts, invoices, timesheets, and driving costs for people in the music industry.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
