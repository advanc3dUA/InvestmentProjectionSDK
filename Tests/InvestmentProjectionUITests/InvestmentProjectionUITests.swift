//
//  InvestmentProjectionUITests.swift
//  
//
//  Created by Yuriy Gudimov on 08.05.26.
//

import Testing
import Foundation
import InvestmentProjectionCore
@testable import InvestmentProjectionUI

struct InvestmentProjectionUITests {
    @Test func germanLocaleLoadsGermanCopyFromStringCatalog() {
        let localization = ProjectionLocalization(locale: Locale(identifier: "de_DE"))

        #expect(localization.navigationTitle == "Prognose")
        #expect(localization.monthlyTitle == "Monatlich")
        #expect(localization.invalidYearsMessage(lowerBound: 1, upperBound: 50) == "Jahre müssen zwischen 1 und 50 liegen.")
    }

    @Test func viewModelUsesLocalizedValidationMessage() {
        let viewModel = InvestmentProjectionViewModel(
            initialInput: nil,
            configuration: .default,
            calculator: ProjectionCalculator(),
            localization: ProjectionLocalization(locale: Locale(identifier: "de_DE")),
            baseCalendarYear: 2026
        )
        var formInput = viewModel.initialState().formInput
        formInput.investmentYearsSelection = .custom
        formInput.customInvestmentYearsText = "0"

        let state = viewModel.state(for: formInput)

        #expect(state.validationMessage == "Jahre müssen zwischen 1 und 50 liegen.")
    }

    @Test func viewModelExposesAnnualRateOptionsFromConfiguration() {
        let configuration = ProjectionConfiguration(annualRatePresets: [3, 7, 11])
        let viewModel = InvestmentProjectionViewModel(
            initialInput: ProjectionInput(
                currentBalance: 0,
                contributionAmount: 100,
                contributionFrequency: .monthly,
                investmentYears: 5,
                annualRate: 7
            ),
            configuration: configuration,
            calculator: ProjectionCalculator(),
            localization: ProjectionLocalization(locale: Locale(identifier: "en_US")),
            baseCalendarYear: 2026
        )

        let state = viewModel.initialState()

        #expect(state.investmentYearOptions.map(\.years) == [5, 10, 20])
        #expect(state.annualRateOptions.map(\.rate) == [3, 7, 11])
        #expect(state.annualRateOptions.map(\.title) == ["3%", "7%", "11%"])
        #expect(state.formInput.investmentYearsSelection == .preset(5))
        #expect(state.formInput.annualRateSelection == .preset(7))
        #expect(state.result?.selectedYearText == "2031")
    }

    @Test func viewModelTreatsNonPresetAnnualRateAsCustom() {
        let configuration = ProjectionConfiguration(
            annualRatePresets: [3, 7],
            investmentYearPresets: [5, 10, 20]
        )
        let viewModel = InvestmentProjectionViewModel(
            initialInput: ProjectionInput(
                currentBalance: 0,
                contributionAmount: 100,
                contributionFrequency: .monthly,
                investmentYears: 12,
                annualRate: 9.5
            ),
            configuration: configuration,
            calculator: ProjectionCalculator(),
            localization: ProjectionLocalization(locale: Locale(identifier: "en_US")),
            baseCalendarYear: 2026
        )

        let state = viewModel.initialState()

        #expect(state.investmentYearOptions.map(\.years) == [5, 10, 20])
        #expect(state.annualRateOptions.map(\.rate) == [3, 7])
        #expect(state.formInput.investmentYearsSelection == .custom)
        #expect(state.formInput.customInvestmentYearsText == "12")
        #expect(state.formInput.annualRateSelection == .custom)
        #expect(state.formInput.customAnnualRateText == "9.5")
    }
}
