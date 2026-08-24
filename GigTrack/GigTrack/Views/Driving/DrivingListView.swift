import SwiftUI
import SwiftData

struct DrivingListView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode
    @Query(sort: \DrivingTrip.date, order: .reverse) private var trips: [DrivingTrip]

    @State private var showingAddSheet = false
    @State private var tripToEdit: DrivingTrip?

    private var totalMiles: Double {
        trips.reduce(0) { $0 + $1.miles }
    }

    private var totalCost: Double {
        trips.reduce(0) { $0 + $1.cost }
    }

    var body: some View {
        List {
            if !trips.isEmpty {
                StatCardRow(cards: [
                    ("Total Miles", totalMiles.formatted(), .accentColor),
                    ("Total Cost", Formatters.currency(totalCost, code: currencyCode), .green)
                ])
            }

            if trips.isEmpty {
                EmptyStateView(
                    systemImage: "car",
                    title: "No Trips Yet",
                    message: "Log a trip to calculate driving costs using your mileage rate."
                )
                .listRowSeparator(.hidden)
            } else {
                Section {
                    ForEach(trips) { trip in
                        Button {
                            tripToEdit = trip
                        } label: {
                            TripRowView(trip: trip)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteTrips)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Driving")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Trip", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddEditTripView(trip: nil)
        }
        .sheet(item: $tripToEdit) { trip in
            AddEditTripView(trip: trip)
        }
    }

    private func deleteTrips(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(trips[index])
        }
    }
}

#Preview {
    NavigationStack {
        DrivingListView()
    }
    .modelContainer(for: [DrivingTrip.self], inMemory: true)
}
