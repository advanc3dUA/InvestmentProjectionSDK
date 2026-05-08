import InvestmentProjectionCore
import Foundation
import UIKit

public enum InvestmentProjectionFlowFactory {
    @MainActor
    public static func makeViewController(
        initialInput: ProjectionInput? = nil,
        configuration: ProjectionConfiguration = .default,
        theme: InvestmentProjectionTheme = .default,
        locale: Locale = .current,
        currencyCode: String = "EUR"
    ) -> UIViewController {
        InvestmentProjectionViewController(
            initialInput: initialInput,
            configuration: configuration,
            theme: theme,
            locale: locale,
            currencyCode: currencyCode
        )
    }
}
