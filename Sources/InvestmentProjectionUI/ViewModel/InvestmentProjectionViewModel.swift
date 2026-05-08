import Foundation
import InvestmentProjectionCore

final class InvestmentProjectionViewModel {
    private let calculator: ProjectionCalculator
    private let configuration: ProjectionConfiguration
    private let formatter: ProjectionValueFormatter
    private let initialInput: ProjectionInput?

    init(
        initialInput: ProjectionInput?,
        configuration: ProjectionConfiguration,
        calculator: ProjectionCalculator,
        formatter: ProjectionValueFormatter = ProjectionValueFormatter()
    ) {
        self.initialInput = initialInput
        self.configuration = configuration
        self.calculator = calculator
        self.formatter = formatter
    }

    func initialState() -> InvestmentProjectionViewState {
        state(for: initialFormInput())
    }

    func state(for formInput: ProjectionFormInput) -> InvestmentProjectionViewState {
        do {
            let input = makeProjectionInput(from: formInput)
            let result = try calculator.calculate(input: input, configuration: configuration)

            return InvestmentProjectionViewState(
                formInput: formInput,
                result: ProjectionResultViewState(
                    finalBalanceText: formatter.currencyString(from: result.finalBalance),
                    totalContributionsText: formatter.currencyString(from: result.totalContributions),
                    totalGrowthText: formatter.currencyString(from: result.totalGrowth),
                    chartPoints: result.yearlyProjection
                ),
                validationMessage: nil
            )
        } catch {
            return InvestmentProjectionViewState(
                formInput: formInput,
                result: nil,
                validationMessage: message(for: error)
            )
        }
    }

    private func initialFormInput() -> ProjectionFormInput {
        let input = initialInput ?? ProjectionInput(
            currentBalance: 0,
            contributionAmount: 100,
            contributionFrequency: .monthly,
            investmentYears: 5,
            annualRate: configuration.fallbackAnnualRate
        )
        let annualRate = input.annualRate ?? configuration.fallbackAnnualRate

        return ProjectionFormInput(
            currentBalanceText: formatter.decimalString(from: input.currentBalance),
            contributionAmountText: formatter.decimalString(from: input.contributionAmount),
            contributionFrequency: input.contributionFrequency,
            investmentYearsText: "\(input.investmentYears)",
            annualRateSelection: rateSelection(for: annualRate),
            customAnnualRateText: formatter.decimalString(from: annualRate)
        )
    }

    private func makeProjectionInput(from formInput: ProjectionFormInput) -> ProjectionInput {
        ProjectionInput(
            currentBalance: decimal(from: formInput.currentBalanceText) ?? 0,
            contributionAmount: decimal(from: formInput.contributionAmountText) ?? 0,
            contributionFrequency: formInput.contributionFrequency,
            investmentYears: Int(formInput.investmentYearsText) ?? 0,
            annualRate: annualRate(from: formInput),
            compoundingFrequency: nil
        )
    }

    private func rateSelection(for annualRate: Decimal) -> AnnualRateSelection {
        switch annualRate {
        case 2.5:
            .preset(2.5)
        case 5:
            .preset(5)
        case 10:
            .preset(10)
        default:
            .custom
        }
    }

    private func annualRate(from formInput: ProjectionFormInput) -> Decimal? {
        switch formInput.annualRateSelection {
        case let .preset(rate):
            rate
        case .custom:
            decimal(from: formInput.customAnnualRateText)
        }
    }

    private func decimal(from text: String) -> Decimal? {
        guard !text.isEmpty else {
            return nil
        }

        return Decimal(string: text.replacingOccurrences(of: ",", with: "."))
    }

    private func message(for error: Error) -> String {
        guard let error = error as? ProjectionValidationError else {
            return "Unable to calculate projection."
        }

        switch error {
        case .negativeCurrentBalance:
            return "Current balance must be zero or greater."
        case .negativeContributionAmount:
            return "Contribution must be zero or greater."
        case let .invalidInvestmentYears(_, allowedRange):
            return "Years must be between \(allowedRange.lowerBound) and \(allowedRange.upperBound)."
        case let .invalidAnnualRate(_, allowedRange):
            return "Annual rate must be between \(allowedRange.lowerBound)% and \(allowedRange.upperBound)%."
        case let .invalidConfiguration(message):
            return message
        }
    }
}
