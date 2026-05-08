import Foundation

public struct ProjectionConfiguration: Sendable {
    public var fallbackAnnualRate: Decimal
    public var annualRatePresets: [Decimal]
    public var defaultCompoundingFrequency: CompoundingFrequency
    public var maximumInvestmentYears: Int
    public var maximumAnnualRate: Decimal

    public init(
        fallbackAnnualRate: Decimal = 2.5,
        annualRatePresets: [Decimal] = [2.5, 5, 10],
        defaultCompoundingFrequency: CompoundingFrequency = .monthly,
        maximumInvestmentYears: Int = 50,
        maximumAnnualRate: Decimal = 100
    ) {
        self.fallbackAnnualRate = fallbackAnnualRate
        self.annualRatePresets = annualRatePresets
        self.defaultCompoundingFrequency = defaultCompoundingFrequency
        self.maximumInvestmentYears = maximumInvestmentYears
        self.maximumAnnualRate = maximumAnnualRate
    }

    public static let `default` = ProjectionConfiguration()
}
