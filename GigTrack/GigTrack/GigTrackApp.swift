import SwiftUI
import SwiftData

@main
struct GigTrackApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Person.self,
            TimeEntry.self,
            Client.self,
            InvoiceLineItem.self,
            Invoice.self,
            Receipt.self,
            DrivingTrip.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
