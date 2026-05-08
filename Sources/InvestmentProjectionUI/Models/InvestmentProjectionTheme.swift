import UIKit

public struct InvestmentProjectionTheme: Sendable {
    public var backgroundColor: UIColor
    public var surfaceColor: UIColor
    public var primaryTextColor: UIColor
    public var secondaryTextColor: UIColor
    public var accentColor: UIColor
    public var positiveColor: UIColor
    public var borderColor: UIColor
    public var cornerRadius: CGFloat

    public init(
        backgroundColor: UIColor = .systemBackground,
        surfaceColor: UIColor = .secondarySystemBackground,
        primaryTextColor: UIColor = .label,
        secondaryTextColor: UIColor = .secondaryLabel,
        accentColor: UIColor = .systemGreen,
        positiveColor: UIColor = .systemTeal,
        borderColor: UIColor = .separator,
        cornerRadius: CGFloat = 8
    ) {
        self.backgroundColor = backgroundColor
        self.surfaceColor = surfaceColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.accentColor = accentColor
        self.positiveColor = positiveColor
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
    }

    public static let `default` = InvestmentProjectionTheme()
}
