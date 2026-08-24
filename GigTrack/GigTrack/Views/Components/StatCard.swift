import SwiftUI

/// Small metric card used at the top of list screens (e.g. "Unpaid Total", "Hours This Week").
struct StatCard: View {
    let title: String
    let value: String
    var color: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)))
    }
}

struct StatCardRow: View {
    let cards: [(title: String, value: String, color: Color)]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(cards.enumerated()), id: \.offset) { _, card in
                StatCard(title: card.title, value: card.value, color: card.color)
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    List {
        StatCardRow(cards: [("Unpaid", "$1,240.00", .orange), ("Paid", "$3,000.00", .green)])
    }
}
