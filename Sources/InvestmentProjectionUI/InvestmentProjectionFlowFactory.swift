import InvestmentProjectionCore
import UIKit

public enum InvestmentProjectionFlowFactory {
    @MainActor
    public static func makeViewController(
initialInput: ProjectionInput? = nil,
        configuration: ProjectionConfiguration = .default,
        theme: InvestmentProjectionTheme = .default
    ) -> UIViewController {
        InvestmentProjectionViewController(initialInput: initialInput, configuration: configuration, theme: theme)
    }
}
