import Foundation

struct ProjectionValueFormatter {
    private let decimalFormatter: NumberFormatter
    private let currencyFormatter: NumberFormatter

    init(locale: Locale = .current, currencyCode: String = "EUR") {
        decimalFormatter = NumberFormatter()
        decimalFormatter.locale = locale
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.maximumFractionDigits = 2
        decimalFormatter.minimumFractionDigits = 0

        currencyFormatter = NumberFormatter()
        currencyFormatter.locale = locale
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = currencyCode
        currencyFormatter.maximumFractionDigits = 0
        currencyFormatter.minimumFractionDigits = 0
    }

    func decimalString(from value: Decimal) -> String {
        decimalFormatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    func currencyString(from value: Decimal) -> String {
        currencyFormatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    func decimal(from text: String) -> Decimal? {
        guard !text.isEmpty else {
            return nil
        }

        if let number = decimalFormatter.number(from: text) {
            return number.decimalValue
        }

        return Decimal(string: text.replacingOccurrences(of: ",", with: "."))
    }
}
