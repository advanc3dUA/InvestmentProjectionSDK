import Foundation
import InvestmentProjectionCore

final class InvestmentProjectionViewModel {
    private let calculator: ProjectionCalculator
    private let configuration: ProjectionConfiguration
    private let formatter: ProjectionValueFormatter
    private let localization: ProjectionLocalization
    private let initialInput: ProjectionInput?
    private let baseCalendarYear: Int

    init(
        initialInput: ProjectionInput?,
        configuration: ProjectionConfiguration,
        calculator: ProjectionCalculator,
        localization: ProjectionLocalization,
        baseCalendarYear: Int = Calendar.current.component(.year, from: Date()),
        formatter: ProjectionValueFormatter? = nil
    ) {
        self.initialInput = initialInput
        self.configuration = configuration
        self.calculator = calculator
        self.localization = localization
        self.baseCalendarYear = baseCalendarYear
        self.formatter = formatter ?? ProjectionValueFormatter(
            locale: localization.locale,
            currencyCode: localization.currencyCode
        )
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
                investmentYearOptions: investmentYearOptions(),
                annualRateOptions: annualRateOptions(),
                result: ProjectionResultViewState(
                    finalBalanceText: formatter.currencyString(from: result.finalBalance),
                    totalContributionsText: formatter.currencyString(from: result.totalContributions),
                    totalGrowthText: formatter.currencyString(from: result.totalGrowth),
                    chartPoints: result.yearlyProjection,
                    baseCalendarYear: baseCalendarYear,
                    selectedYearText: "\(baseCalendarYear + (result.yearlyProjection.last?.year ?? input.investmentYears))"
                ),
                validationMessage: nil
            )
        } catch {
            return InvestmentProjectionViewState(
                formInput: formInput,
                investmentYearOptions: investmentYearOptions(),
                annualRateOptions: annualRateOptions(),
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
            investmentYearsSelection: yearsSelection(for: input.investmentYears),
            customInvestmentYearsText: "\(input.investmentYears)",
            annualRateSelection: rateSelection(for: annualRate),
            customAnnualRateText: formatter.decimalString(from: annualRate)
        )
    }

    private func makeProjectionInput(from formInput: ProjectionFormInput) -> ProjectionInput {
        ProjectionInput(
            currentBalance: formatter.decimal(from: formInput.currentBalanceText) ?? 0,
            contributionAmount: formatter.decimal(from: formInput.contributionAmountText) ?? 0,
            contributionFrequency: formInput.contributionFrequency,
            investmentYears: investmentYears(from: formInput),
            annualRate: annualRate(from: formInput),
            compoundingFrequency: nil
        )
    }

    private func yearsSelection(for investmentYears: Int) -> InvestmentYearsSelection {
        configuration.investmentYearPresets.contains(investmentYears) ? .preset(investmentYears) : .custom
    }

    private func rateSelection(for annualRate: Decimal) -> AnnualRateSelection {
        configuration.annualRatePresets.contains(annualRate) ? .preset(annualRate) : .custom
    }

    private func annualRate(from formInput: ProjectionFormInput) -> Decimal? {
        switch formInput.annualRateSelection {
        case let .preset(rate):
            rate
        case .custom:
            formatter.decimal(from: formInput.customAnnualRateText)
        }
    }

    private func investmentYears(from formInput: ProjectionFormInput) -> Int {
        switch formInput.investmentYearsSelection {
        case let .preset(years):
            years
        case .custom:
            Int(formInput.customInvestmentYearsText) ?? 0
        }
    }

    private func message(for error: Error) -> String {
        guard let error = error as? ProjectionValidationError else {
            return localization.calculationFallbackMessage
        }

        switch error {
        case .negativeCurrentBalance:
            return localization.negativeCurrentBalanceMessage
        case .negativeContributionAmount:
            return localization.negativeContributionAmountMessage
        case let .invalidInvestmentYears(_, allowedRange):
            return localization.invalidYearsMessage(
                lowerBound: allowedRange.lowerBound,
                upperBound: allowedRange.upperBound
            )
        case let .invalidAnnualRate(_, allowedRange):
            return localization.invalidAnnualRateMessage(
                lowerBound: allowedRange.lowerBound,
                upperBound: allowedRange.upperBound
            )
        case let .invalidConfiguration(message):
            return message
        }
    }

    private func annualRateOptions() -> [AnnualRateOption] {
        configuration.annualRatePresets.map {
            AnnualRateOption(rate: $0, title: "\(formatter.decimalString(from: $0))%")
        }
    }

    private func investmentYearOptions() -> [InvestmentYearOption] {
        configuration.investmentYearPresets.map {
            InvestmentYearOption(years: $0, title: "\($0)")
        }
    }
}
