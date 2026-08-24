import SwiftUI

struct TripRowView: View {
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode
    let trip: DrivingTrip

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(routeText)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                if !trip.purpose.isEmpty {
                    Text(trip.purpose)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(Formatters.mediumDate.string(from: trip.date))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(Formatters.currency(trip.cost, code: currencyCode))
                    .font(.body.weight(.semibold))
                Text("\(trip.miles.formatted()) mi")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var routeText: String {
        if trip.startLocation.isEmpty && trip.endLocation.isEmpty {
            return "Trip"
        }
        return "\(trip.startLocation) → \(trip.endLocation)"
    }
}
