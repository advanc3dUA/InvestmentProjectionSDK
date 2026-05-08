import Foundation

public struct ProjectionInput: Sendable {
    public var currentBalance: Decimal
    public var contributionAmount: Decimal
    public var contributionFrequency: ContributionFrequency
    public var investmentYears: Int
    public var annualRate: Decimal?
    public var compoundingFrequency: CompoundingFrequency?

    public init(
        currentBalance: Decimal = 0,
        contributionAmount: Decimal = 0,
        contributionFrequency: ContributionFrequency = .monthly,
        investmentYears: Int,
        annualRate: Decimal? = nil,
        compoundingFrequency: CompoundingFrequency? = nil
    ) {
        self.currentBalance = currentBalance
        self.contributionAmount = contributionAmount
        self.contributionFrequency = contributionFrequency
        self.investmentYears = investmentYears
        self.annualRate = annualRate
        self.compoundingFrequency = compoundingFrequency
    }
}
