import Foundation

public struct ProjectionResult: Equatable, Sendable {
    public let finalBalance: Decimal
    public let totalContributions: Decimal
    public let totalGrowth: Decimal
    public let effectiveAnnualRateUsed: Decimal
    public let yearlyProjection: [ProjectionYearPoint]

    public init(
        finalBalance: Decimal,
        totalContributions: Decimal,
        totalGrowth: Decimal,
        effectiveAnnualRateUsed: Decimal,
        yearlyProjection: [ProjectionYearPoint]
    ) {
        self.finalBalance = finalBalance
        self.totalContributions = totalContributions
        self.totalGrowth = totalGrowth
        self.effectiveAnnualRateUsed = effectiveAnnualRateUsed
        self.yearlyProjection = yearlyProjection
    }
}
