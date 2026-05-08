import Foundation

struct ProjectionLocalization {
    let locale: Locale
    let currencyCode: String

    var navigationTitle: String { string("projection.navigation.title") }
    var headlineTitle: String { string("projection.headline.title") }
    var headlineSubtitle: String { string("projection.headline.subtitle") }
    var currentBalanceTitle: String { string("projection.input.current_balance") }
    var contributionTitle: String { string("projection.input.contribution") }
    var frequencyTitle: String { string("projection.input.frequency") }
    var yearsTitle: String { string("projection.input.years") }
    var annualRateTitle: String { string("projection.input.annual_rate") }
    var customRateTitle: String { string("projection.input.custom_rate") }
    var monthlyTitle: String { string("projection.frequency.monthly") }
    var yearlyTitle: String { string("projection.frequency.yearly") }
    var customTitle: String { string("projection.rate.custom") }
    var projectedValueTitle: String { string("projection.result.projected_value") }
    var contributedTitle: String { string("projection.result.contributed") }
    var growthTitle: String { string("projection.result.growth") }
    var calculationFallbackMessage: String { string("projection.validation.calculation_failed") }
    var negativeCurrentBalanceMessage: String { string("projection.validation.negative_current_balance") }
    var negativeContributionAmountMessage: String { string("projection.validation.negative_contribution") }

    init(locale: Locale = .current, currencyCode: String = "EUR") {
        self.locale = locale
        self.currencyCode = currencyCode
    }

    func invalidYearsMessage(lowerBound: Int, upperBound: Int) -> String {
        String(
            format: string("projection.validation.invalid_years"),
            locale: locale,
            "\(lowerBound)",
            "\(upperBound)"
        )
    }

    func invalidAnnualRateMessage(lowerBound: Decimal, upperBound: Decimal) -> String {
        String(
            format: string("projection.validation.invalid_annual_rate"),
            locale: locale,
            formattedDecimal(lowerBound),
            formattedDecimal(upperBound)
        )
    }

    private func string(_ key: String) -> String {
        localizationBundle.localizedString(forKey: key, value: nil, table: "Localizable")
    }

    private var localizationBundle: Bundle {
        guard
            let path = Bundle.module.path(forResource: localizationCode, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return .module
        }

        return bundle
    }

    private var localizationCode: String {
        let identifier = locale.identifier.lowercased()
        return identifier.hasPrefix("de") ? "de" : "en"
    }

    private func formattedDecimal(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }
}
