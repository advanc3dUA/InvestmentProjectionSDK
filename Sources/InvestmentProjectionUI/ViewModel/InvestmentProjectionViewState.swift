import Foundation
import InvestmentProjectionCore

struct InvestmentProjectionViewState {
    let formInput: ProjectionFormInput
    let result: ProjectionResultViewState?
    let validationMessage: String?

    var isCustomRateVisible: Bool {
        formInput.annualRateSelection == .custom
    }
}

struct ProjectionFormInput: Equatable {
    var currentBalanceText: String
    var contributionAmountText: String
    var contributionFrequency: ContributionFrequency
    var investmentYearsText: String
    var annualRateSelection: AnnualRateSelection
    var customAnnualRateText: String
}

enum AnnualRateSelection: Equatable {
    case preset(Decimal)
    case custom
}

struct ProjectionResultViewState {
    let finalBalanceText: String
    let totalContributionsText: String
    let totalGrowthText: String
    let chartPoints: [ProjectionYearPoint]
}
