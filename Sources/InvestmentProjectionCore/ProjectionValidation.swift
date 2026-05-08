import Foundation

public struct ProjectionValidator: Sendable {
    public init() {}

    public func validate(input: ProjectionInput, configuration: ProjectionConfiguration) throws -> Decimal {
        guard configuration.maximumInvestmentYears > 0 else {
            throw ProjectionValidationError.invalidConfiguration("maximumInvestmentYears must be greater than zero.")
        }

        guard configuration.maximumAnnualRate >= 0 else {
            throw ProjectionValidationError.invalidConfiguration("maximumAnnualRate must be greater than or equal to zero.")
        }

        guard configuration.fallbackAnnualRate >= 0,
              configuration.fallbackAnnualRate <= configuration.maximumAnnualRate
        else {
            throw ProjectionValidationError.invalidConfiguration("fallbackAnnualRate must be within the allowed annual rate range.")
        }

        guard input.currentBalance >= 0 else {
            throw ProjectionValidationError.negativeCurrentBalance
        }

        guard input.contributionAmount >= 0 else {
            throw ProjectionValidationError.negativeContributionAmount
        }

        let yearsRange = 1...configuration.maximumInvestmentYears
        guard yearsRange.contains(input.investmentYears) else {
            throw ProjectionValidationError.invalidInvestmentYears(
                actual: input.investmentYears,
                allowedRange: yearsRange
            )
        }

        let annualRate = input.annualRate ?? configuration.fallbackAnnualRate
        let annualRateRange: ClosedRange<Decimal> = 0...configuration.maximumAnnualRate
        guard annualRateRange.contains(annualRate) else {
            throw ProjectionValidationError.invalidAnnualRate(
                actual: annualRate,
                allowedRange: annualRateRange
            )
        }

        return annualRate
    }
}
