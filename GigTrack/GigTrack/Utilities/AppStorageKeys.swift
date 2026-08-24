import Foundation

/// Central place for `@AppStorage` keys and app-wide defaults, so the same
/// key/default is never typed twice.
enum AppStorageKeys {
    static let currencyCode = "currencyCode"
    static let defaultMileageRate = "defaultMileageRate"
    static let businessName = "businessName"
    static let businessEmail = "businessEmail"

    static let defaultCurrencyCode = Locale.current.currency?.identifier ?? "USD"
    /// IRS standard business mileage rate is used only as a sane starting default;
    /// users can change it any time in Settings.
    static let defaultMileageRateValue = 0.67
}
