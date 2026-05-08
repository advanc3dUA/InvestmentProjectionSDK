import UIKit

public struct InvestmentProjectionTheme: Sendable {
    public var backgroundColor: UIColor
    public var surfaceColor: UIColor
    public var primaryTextColor: UIColor
    public var secondaryTextColor: UIColor
    public var accentColor: UIColor
    public var positiveColor: UIColor
    public var borderColor: UIColor
    public var inputBackgroundColor: UIColor
    public var inputTextColor: UIColor
    public var controlBackgroundColor: UIColor
    public var errorTextColor: UIColor
    public var selectedControlTextColor: UIColor
    public var cornerRadius: CGFloat
    public var surfaceBorderWidth: CGFloat
    public var contentInsets: UIEdgeInsets
    public var contentSpacing: CGFloat
    public var surfaceInsets: UIEdgeInsets
    public var surfaceSpacing: CGFloat
    public var rowSpacing: CGFloat
    public var inputCornerRadius: CGFloat
    public var inputHeight: CGFloat
    public var inputHorizontalPadding: CGFloat
    public var keyboardAppearance: UIKeyboardAppearance

    public init(
        backgroundColor: UIColor = .systemBackground,
        surfaceColor: UIColor = .secondarySystemBackground,
        primaryTextColor: UIColor = .label,
        secondaryTextColor: UIColor = .secondaryLabel,
        accentColor: UIColor = .systemGreen,
        positiveColor: UIColor = .systemTeal,
        borderColor: UIColor = .separator,
        inputBackgroundColor: UIColor = .tertiarySystemBackground,
        inputTextColor: UIColor = .label,
        controlBackgroundColor: UIColor = .tertiarySystemFill,
        errorTextColor: UIColor = .systemRed,
        selectedControlTextColor: UIColor = .systemBackground,
        cornerRadius: CGFloat = 8,
        surfaceBorderWidth: CGFloat = 0.5,
        contentInsets: UIEdgeInsets = UIEdgeInsets(top: 24, left: 20, bottom: 32, right: 20),
        contentSpacing: CGFloat = 16,
        surfaceInsets: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
        surfaceSpacing: CGFloat = 12,
        rowSpacing: CGFloat = 6,
        inputCornerRadius: CGFloat = 8,
        inputHeight: CGFloat = 46,
        inputHorizontalPadding: CGFloat = 12,
        keyboardAppearance: UIKeyboardAppearance = .default
    ) {
        self.backgroundColor = backgroundColor
        self.surfaceColor = surfaceColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.accentColor = accentColor
        self.positiveColor = positiveColor
        self.borderColor = borderColor
        self.inputBackgroundColor = inputBackgroundColor
        self.inputTextColor = inputTextColor
        self.controlBackgroundColor = controlBackgroundColor
        self.errorTextColor = errorTextColor
        self.selectedControlTextColor = selectedControlTextColor
        self.cornerRadius = cornerRadius
        self.surfaceBorderWidth = surfaceBorderWidth
        self.contentInsets = contentInsets
        self.contentSpacing = contentSpacing
        self.surfaceInsets = surfaceInsets
        self.surfaceSpacing = surfaceSpacing
        self.rowSpacing = rowSpacing
        self.inputCornerRadius = inputCornerRadius
        self.inputHeight = inputHeight
        self.inputHorizontalPadding = inputHorizontalPadding
        self.keyboardAppearance = keyboardAppearance
    }

    public static let `default` = InvestmentProjectionTheme()
}
