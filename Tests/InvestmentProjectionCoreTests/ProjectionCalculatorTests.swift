import Foundation
import Testing
@testable import InvestmentProjectionCore

struct ProjectionCalculatorTests {
    private let calculator = ProjectionCalculator()

    @Test
    func zeroBalanceAndZeroContributionProducesZeroProjection() throws {
        let input = ProjectionInput(
            currentBalance: 0,
            contributionAmount: 0,
            contributionFrequency: .monthly,
            investmentYears: 5,
            annualRate: 5
        )

        let result = try calculator.calculate(input: input)

        #expect(result.finalBalance.isApproximatelyEqual(to: 0))
        #expect(result.totalContributions.isApproximatelyEqual(to: 0))
        #expect(result.totalGrowth.isApproximatelyEqual(to: 0))
        #expect(result.yearlyProjection.count == 5)
    }

    @Test
    func startingBalanceCompoundsUsingAnnualRate() throws {
        let input = ProjectionInput(
            currentBalance: 1_000,
            contributionAmount: 0,
            contributionFrequency: .monthly,
            investmentYears: 1,
            annualRate: 5
        )

        let result = try calculator.calculate(input: input)

        #expect(result.finalBalance.isApproximatelyEqual(to: 1_050))
        #expect(result.totalContributions.isApproximatelyEqual(to: 1_000))
        #expect(result.totalGrowth.isApproximatelyEqual(to: 50))
    }

    @Test
    func monthlyContributionIsAppliedAtBeginningOfEachMonth() throws {
        let input = ProjectionInput(
            currentBalance: 0,
            contributionAmount: 100,
            contributionFrequency: .monthly,
            investmentYears: 1,
            annualRate: 0
        )

        let result = try calculator.calculate(input: input)

        #expect(result.finalBalance.isApproximatelyEqual(to: 1_200))
        #expect(result.totalContributions.isApproximatelyEqual(to: 1_200))
        #expect(result.totalGrowth.isApproximatelyEqual(to: 0))
    }

    @Test
    func yearlyContributionIsAppliedAtBeginningOfEachInvestmentYear() throws {
        let input = ProjectionInput(
            currentBalance: 0,
            contributionAmount: 1_200,
            contributionFrequency: .yearly,
            investmentYears: 2,
            annualRate: 0
        )

        let result = try calculator.calculate(input: input)

        #expect(result.finalBalance.isApproximatelyEqual(to: 2_400))
        #expect(result.totalContributions.isApproximatelyEqual(to: 2_400))
        #expect(result.yearlyProjection.map(\.contributionsToDate) == [1_200, 2_400])
    }

    @Test
    func fallbackAnnualRateIsUsedWhenInputDoesNotProvideRate() throws {
        let configuration = ProjectionConfiguration(fallbackAnnualRate: 2.5)
        let input = ProjectionInput(
            currentBalance: 1_000,
            contributionAmount: 0,
            contributionFrequency: .monthly,
            investmentYears: 1,
            annualRate: nil
        )

        let result = try calculator.calculate(input: input, configuration: configuration)

        #expect(result.effectiveAnnualRateUsed.isApproximatelyEqual(to: 2.5))
        #expect(result.finalBalance.isApproximatelyEqual(to: 1_025))
    }

    @Test
    func yearlyProjectionContainsOnePointPerInvestmentYear() throws {
        let input = ProjectionInput(
            currentBalance: 500,
            contributionAmount: 50,
            contributionFrequency: .monthly,
            investmentYears: 3,
            annualRate: 0
        )

        let result = try calculator.calculate(input: input)

        #expect(result.yearlyProjection.map(\.year) == [1, 2, 3])
        #expect(result.yearlyProjection.last?.balance.isApproximatelyEqual(to: 2_300) == true)
    }

    @Test
    func negativeCurrentBalanceFailsValidation() {
        let input = ProjectionInput(
            currentBalance: -1,
            contributionAmount: 0,
            contributionFrequency: .monthly,
            investmentYears: 1,
            annualRate: 5
        )

        expectValidationError(.negativeCurrentBalance) {
            _ = try calculator.calculate(input: input)
        }
    }

    @Test
    func invalidInvestmentYearsFailsValidation() {
        let input = ProjectionInput(
            currentBalance: 0,
            contributionAmount: 0,
            contributionFrequency: .monthly,
            investmentYears: 51,
            annualRate: 5
        )

        expectValidationError(.invalidInvestmentYears(actual: 51, allowedRange: 1...50)) {
            _ = try calculator.calculate(input: input)
        }
    }

    @Test
    func invalidAnnualRateFailsValidation() {
        let input = ProjectionInput(
            currentBalance: 0,
            contributionAmount: 0,
            contributionFrequency: .monthly,
            investmentYears: 1,
            annualRate: 101
        )

        expectValidationError(.invalidAnnualRate(actual: 101, allowedRange: 0...100)) {
            _ = try calculator.calculate(input: input)
        }
    }

    private func expectValidationError(
        _ expectedError: ProjectionValidationError,
        operation: () throws -> Void
    ) {
        do {
            try operation()
            Issue.record("Expected \(expectedError), but operation succeeded.")
        } catch let error as ProjectionValidationError {
            #expect(error == expectedError)
        } catch {
            Issue.record("Expected \(expectedError), but received \(error).")
        }
    }
}

private extension Decimal {
    func isApproximatelyEqual(
        to expectedValue: Decimal,
        tolerance: Decimal = 0.01
    ) -> Bool {
        abs(self - expectedValue) <= tolerance
    }
}
