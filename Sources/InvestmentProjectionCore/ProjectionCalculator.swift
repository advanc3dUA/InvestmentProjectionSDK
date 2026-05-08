import Foundation

public struct ProjectionCalculator: Sendable {
    private let validator: ProjectionValidator

    public init(validator: ProjectionValidator = ProjectionValidator()) {
        self.validator = validator
    }

    public func calculate(input: ProjectionInput, configuration: ProjectionConfiguration = .default) throws -> ProjectionResult {
        let annualRate = try validator.validate(input: input, configuration: configuration)
        let compoundingFrequency = input.compoundingFrequency ?? configuration.defaultCompoundingFrequency
        let monthlyRate = monthlyRate(forAnnualRate: annualRate, compoundingFrequency: compoundingFrequency)
        let yearlyRate = annualRate / 100

        var balance = input.currentBalance
        var totalContributions = input.currentBalance
        var yearlyProjection: [ProjectionYearPoint] = []

        for month in 1...(input.investmentYears * 12) {
            let contribution = contributionAmount(forMonth: month, input: input)

            balance += contribution
            totalContributions += contribution

            switch compoundingFrequency {
            case .monthly:
                balance *= 1 + monthlyRate
            case .yearly:
                if month.isMultiple(of: 12) {
                    balance *= 1 + yearlyRate
                }
            }

            if month.isMultiple(of: 12) {
                yearlyProjection.append(
                    ProjectionYearPoint(
                        year: month / 12,
                        balance: balance,
                        contributionsToDate: totalContributions,
                        growthToDate: balance - totalContributions
                    )
                )
            }
        }

        return ProjectionResult(
            finalBalance: balance,
            totalContributions: totalContributions,
            totalGrowth: balance - totalContributions,
            effectiveAnnualRateUsed: annualRate,
            yearlyProjection: yearlyProjection
        )
    }

    private func contributionAmount(forMonth month: Int, input: ProjectionInput) -> Decimal {
        switch input.contributionFrequency {
        case .monthly:
            input.contributionAmount
        case .yearly:
            (month - 1).isMultiple(of: 12) ? input.contributionAmount : 0
        }
    }

    private func monthlyRate(forAnnualRate annualRate: Decimal, compoundingFrequency: CompoundingFrequency) -> Decimal {
        guard annualRate > 0, compoundingFrequency == .monthly else {
            return 0
        }

        let annualRateDouble = NSDecimalNumber(decimal: annualRate).doubleValue / 100
        return Decimal(pow(1 + annualRateDouble, 1.0 / 12.0) - 1)
    }
}
