import Foundation

public enum ProjectionValidationError: Error, Equatable, Sendable {
    case negativeCurrentBalance
    case negativeContributionAmount
    case invalidInvestmentYears(actual: Int, allowedRange: ClosedRange<Int>)
    case invalidAnnualRate(actual: Decimal, allowedRange: ClosedRange<Decimal>)
    case invalidConfiguration(String)
}
