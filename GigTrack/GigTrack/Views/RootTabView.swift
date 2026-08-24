import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ReceiptsListView()
            }
            .tabItem { Label("Receipts", systemImage: "receipt") }

            NavigationStack {
                InvoicesListView()
            }
            .tabItem { Label("Invoices", systemImage: "doc.text") }

            NavigationStack {
                TimeTabView()
            }
            .tabItem { Label("Time", systemImage: "clock") }

            NavigationStack {
                DrivingListView()
            }
            .tabItem { Label("Driving", systemImage: "car") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Person.self, TimeEntry.self, Client.self, InvoiceLineItem.self, Invoice.self, Receipt.self, DrivingTrip.self], inMemory: true)
}
