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
            localization: ProjectionLocalization(locale: Locale(identifier: "de_DE"))
        )
        var formInput = viewModel.initialState().formInput
        formInput.investmentYearsText = "0"

        let state = viewModel.state(for: formInput)

        #expect(state.validationMessage == "Jahre müssen zwischen 1 und 50 liegen.")
    }
}
