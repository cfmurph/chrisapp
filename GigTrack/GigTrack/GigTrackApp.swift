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
        // Syncs privately to the signed-in user's own iCloud account across
        // their devices via SwiftData's built-in CloudKit mirroring. This
        // requires the "iCloud" capability (CloudKit service) to be enabled
        // for this target in Xcode with a matching container identifier —
        // see the README for the one-time setup steps. If that hasn't been
        // configured yet, creating the container throws, and we fall back to
        // a local-only store rather than crashing the app.
        let cloudConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            return try ModelContainer(for: schema, configurations: [cloudConfiguration])
        } catch {
            print("⚠️ CloudKit sync unavailable, falling back to a local-only store: \(error)")
            let localConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            do {
                return try ModelContainer(for: schema, configurations: [localConfiguration])
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
