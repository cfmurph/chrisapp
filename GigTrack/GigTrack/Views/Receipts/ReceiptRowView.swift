import SwiftUI
import UIKit

struct ReceiptRowView: View {
    @AppStorage(AppStorageKeys.currencyCode) private var currencyCode = AppStorageKeys.defaultCurrencyCode
    let receipt: Receipt

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 3) {
                Text(receipt.vendor.isEmpty ? "Untitled Receipt" : receipt.vendor)
                    .font(.body.weight(.medium))
                Text(receipt.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(Formatters.mediumDate.string(from: receipt.date))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text(Formatters.currency(receipt.amount, code: currencyCode))
                .font(.body.weight(.semibold))
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let data = receipt.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemFill))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: ReceiptCategory(rawValue: receipt.category)?.systemImage ?? "receipt")
                        .foregroundStyle(.secondary)
                )
        }
    }
}
