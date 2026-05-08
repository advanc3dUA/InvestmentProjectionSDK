import Foundation
import InvestmentProjectionCore

struct InvestmentProjectionViewState {
    let formInput: ProjectionFormInput
    let investmentYearOptions: [InvestmentYearOption]
    let annualRateOptions: [AnnualRateOption]
    let result: ProjectionResultViewState?
    let validationMessage: String?

    var isCustomYearsVisible: Bool {
        formInput.investmentYearsSelection == .custom
    }

    var isCustomRateVisible: Bool {
        formInput.annualRateSelection == .custom
    }
}

struct ProjectionFormInput: Equatable {
    var currentBalanceText: String
    var contributionAmountText: String
    var contributionFrequency: ContributionFrequency
    var investmentYearsSelection: InvestmentYearsSelection
    var customInvestmentYearsText: String
    var annualRateSelection: AnnualRateSelection
    var customAnnualRateText: String
}

enum InvestmentYearsSelection: Equatable {
    case preset(Int)
    case custom
}

struct InvestmentYearOption: Equatable {
    let years: Int
    let title: String
}

enum AnnualRateSelection: Equatable {
    case preset(Decimal)
    case custom
}

struct AnnualRateOption: Equatable {
    let rate: Decimal
    let title: String
}

struct ProjectionResultViewState {
    let finalBalanceText: String
    let totalContributionsText: String
    let totalGrowthText: String
    let chartPoints: [ProjectionYearPoint]
    let baseCalendarYear: Int
    let selectedYearText: String
}
