import SwiftUI
import SwiftData

struct AddEditTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode
    @AppStorage(AppStorageKeys.defaultMileageRate) private var defaultMileageRate = AppStorageKeys.defaultMileageRateValue

    let trip: DrivingTrip?

    @State private var date: Date = .now
    @State private var startLocation = ""
    @State private var endLocation = ""
    @State private var miles: Double = 0
    @State private var ratePerMile: Double = 0
    @State private var purpose = ""
    @State private var notes = ""

    private var isEditing: Bool { trip != nil }
    private var cost: Double { miles * ratePerMile }

    var body: some View {
        NavigationStack {
            Form {
                Section("Route") {
                    TextField("Start Location", text: $startLocation)
                    TextField("End Location", text: $endLocation)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Purpose (e.g. Gig at The Venue)", text: $purpose)
                }

                Section("Cost Calculation") {
                    TextField("Miles Driven", value: $miles, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Rate per Mile", value: $ratePerMile, format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                    HStack {
                        Text("Total Cost").font(.body.weight(.semibold))
                        Spacer()
                        Text(Formatters.currency(cost, code: currencyCode)).font(.body.weight(.semibold))
                    }
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Trip" : "New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .onAppear(perform: populate)
        }
    }

    private func populate() {
        if let trip {
            date = trip.date
            startLocation = trip.startLocation
            endLocation = trip.endLocation
            miles = trip.miles
            ratePerMile = trip.ratePerMile
            purpose = trip.purpose
            notes = trip.notes
        } else {
            ratePerMile = defaultMileageRate
        }
    }

    private func save() {
        if let trip {
            trip.date = date
            trip.startLocation = startLocation
            trip.endLocation = endLocation
            trip.miles = miles
            trip.ratePerMile = ratePerMile
            trip.purpose = purpose
            trip.notes = notes
        } else {
            let newTrip = DrivingTrip(
                date: date,
                startLocation: startLocation,
                endLocation: endLocation,
                miles: miles,
                ratePerMile: ratePerMile,
                purpose: purpose,
                notes: notes
            )
            modelContext.insert(newTrip)
        }
        dismiss()
    }
}

#Preview {
    AddEditTripView(trip: nil)
        .modelContainer(for: [DrivingTrip.self], inMemory: true)
}
