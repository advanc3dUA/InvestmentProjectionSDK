import Foundation

struct ProjectionValueFormatter {
    private let decimalFormatter: NumberFormatter
    private let currencyFormatter: NumberFormatter

    init(currencyCode: String = "EUR") {
        decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.maximumFractionDigits = 2
        decimalFormatter.minimumFractionDigits = 0

        currencyFormatter = NumberFormatter()
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
}
