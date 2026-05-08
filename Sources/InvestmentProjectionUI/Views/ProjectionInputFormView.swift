import InvestmentProjectionCore
import UIKit

final class ProjectionInputFormView: UIStackView {
    var onChange: ((ProjectionFormInput) -> Void)?

    private let theme: InvestmentProjectionTheme
    private let localization: ProjectionLocalization
    private var investmentYearOptions: [InvestmentYearOption] = []
    private var annualRateOptions: [AnnualRateOption] = []
    private let balanceField = UITextField()
    private let contributionField = UITextField()
    private let customYearsField = UITextField()
    private let customRateField = UITextField()
    private let validationLabel = UILabel()
    private let contributionFrequencyControl: UISegmentedControl
    private let yearsPresetControl: UISegmentedControl
    private let ratePresetControl: UISegmentedControl
    private lazy var customYearsRow = makeTextFieldRow(title: localization.customYearsTitle, textField: customYearsField)
    private lazy var customRateRow = makeTextFieldRow(title: localization.customRateTitle, textField: customRateField)
    private var isApplyingState = false

    init(theme: InvestmentProjectionTheme, localization: ProjectionLocalization) {
        self.theme = theme
        self.localization = localization
        self.contributionFrequencyControl = UISegmentedControl(items: [
            localization.monthlyTitle,
            localization.yearlyTitle
        ])
        self.yearsPresetControl = UISegmentedControl()
        self.ratePresetControl = UISegmentedControl()
        super.init(frame: .zero)
        configureView()
    }

    required init(coder: NSCoder) {
        self.theme = .default
        self.localization = ProjectionLocalization(locale: .current)
        self.contributionFrequencyControl = UISegmentedControl(items: [
            self.localization.monthlyTitle,
            self.localization.yearlyTitle
        ])
        self.yearsPresetControl = UISegmentedControl()
        self.ratePresetControl = UISegmentedControl()
        super.init(coder: coder)
        configureView()
    }

    func apply(_ state: InvestmentProjectionViewState) {
        isApplyingState = true
        defer { isApplyingState = false }

        let formInput = state.formInput
        applyInvestmentYearOptions(state.investmentYearOptions)
        applyAnnualRateOptions(state.annualRateOptions)
        balanceField.text = formInput.currentBalanceText
        contributionField.text = formInput.contributionAmountText
        contributionFrequencyControl.selectedSegmentIndex = formInput.contributionFrequency == .monthly ? 0 : 1
        yearsPresetControl.selectedSegmentIndex = yearSegmentIndex(for: formInput.investmentYearsSelection)
        customYearsField.text = formInput.customInvestmentYearsText
        ratePresetControl.selectedSegmentIndex = segmentIndex(for: formInput.annualRateSelection)
        customRateField.text = formInput.customAnnualRateText
        setVisibility(of: customYearsRow, isVisible: state.isCustomYearsVisible, animated: window != nil)
        setVisibility(of: customRateRow, isVisible: state.isCustomRateVisible, animated: window != nil)

        validationLabel.text = state.validationMessage
        validationLabel.isHidden = state.validationMessage == nil
    }

    func updateAppearance() {
        backgroundColor = theme.surfaceColor
        layer.borderColor = theme.borderColor.cgColor

        [balanceField, contributionField, customYearsField, customRateField].forEach {
            $0.backgroundColor = theme.inputBackgroundColor
            $0.textColor = theme.inputTextColor
            $0.tintColor = theme.accentColor
        }

        [contributionFrequencyControl, yearsPresetControl, ratePresetControl].forEach {
            $0.selectedSegmentTintColor = theme.accentColor
            $0.backgroundColor = theme.controlBackgroundColor
            $0.setTitleTextAttributes([.foregroundColor: theme.secondaryTextColor], for: .normal)
            $0.setTitleTextAttributes([.foregroundColor: theme.selectedControlTextColor], for: .selected)
        }

        validationLabel.textColor = theme.errorTextColor
    }

    private func configureView() {
        axis = .vertical
        spacing = theme.surfaceSpacing
        layoutMargins = theme.surfaceInsets
        isLayoutMarginsRelativeArrangement = true
        backgroundColor = theme.surfaceColor
        layer.cornerRadius = theme.cornerRadius
        layer.borderColor = theme.borderColor.cgColor
        layer.borderWidth = theme.surfaceBorderWidth

        addArrangedSubview(makeTextFieldRow(title: localization.currentBalanceTitle, textField: balanceField))
        addArrangedSubview(makeTextFieldRow(title: localization.contributionTitle, textField: contributionField))
        addArrangedSubview(makeControlRow(title: localization.frequencyTitle, control: contributionFrequencyControl))
        addArrangedSubview(customYearsRow)
        addArrangedSubview(makeControlRow(title: localization.yearsTitle, control: yearsPresetControl))
        addArrangedSubview(customRateRow)
        addArrangedSubview(makeControlRow(title: localization.annualRateTitle, control: ratePresetControl))
        addArrangedSubview(validationLabel)

        [balanceField, contributionField, customRateField].forEach {
            configureTextField($0, keyboardType: .decimalPad)
        }
        configureTextField(customYearsField, keyboardType: .numberPad)

        [contributionFrequencyControl, yearsPresetControl, ratePresetControl].forEach {
            $0.selectedSegmentTintColor = theme.accentColor
            $0.backgroundColor = theme.controlBackgroundColor
            $0.setTitleTextAttributes([.foregroundColor: theme.secondaryTextColor], for: .normal)
            $0.setTitleTextAttributes([.foregroundColor: theme.selectedControlTextColor], for: .selected)
            $0.addTarget(self, action: #selector(inputDidChange), for: .valueChanged)
        }

        validationLabel.font = .preferredFont(forTextStyle: .footnote)
        validationLabel.textColor = theme.errorTextColor
        validationLabel.numberOfLines = 0
        validationLabel.isHidden = true

        customYearsRow.isHidden = true
        customYearsRow.alpha = 0
        customRateRow.isHidden = true
        customRateRow.alpha = 0
    }

    private func makeTextFieldRow(title: String, textField: UITextField) -> UIView {
        makeRow(title: title, arrangedView: textField)
    }

    private func makeControlRow(title: String, control: UISegmentedControl) -> UIView {
        makeRow(title: title, arrangedView: control)
    }

    private func makeRow(title: String, arrangedView: UIView) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = theme.rowSpacing

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = theme.secondaryTextColor

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(arrangedView)
        return stack
    }

    private func configureTextField(_ textField: UITextField, keyboardType: UIKeyboardType) {
        textField.borderStyle = .none
        textField.backgroundColor = theme.inputBackgroundColor
        textField.textColor = theme.inputTextColor
        textField.tintColor = theme.accentColor
        textField.keyboardType = keyboardType
        textField.keyboardAppearance = theme.keyboardAppearance
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(inputDidChange), for: .editingChanged)
        textField.layer.cornerRadius = theme.inputCornerRadius
        textField.layer.masksToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: theme.inputHorizontalPadding, height: 1))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: theme.inputHorizontalPadding, height: 1))
        textField.rightViewMode = .unlessEditing
        textField.heightAnchor.constraint(greaterThanOrEqualToConstant: theme.inputHeight).isActive = true
    }

    @objc private func inputDidChange() {
        guard !isApplyingState else {
            return
        }

        let isCustomYearsSelected = yearSelection() == .custom
        let isCustomRateSelected = rateSelection() == .custom
        setVisibility(of: customYearsRow, isVisible: isCustomYearsSelected, animated: true)
        setVisibility(of: customRateRow, isVisible: isCustomRateSelected, animated: true)
        onChange?(currentFormInput())
    }

    private func currentFormInput() -> ProjectionFormInput {
        ProjectionFormInput(
            currentBalanceText: balanceField.text ?? "",
            contributionAmountText: contributionField.text ?? "",
            contributionFrequency: contributionFrequencyControl.selectedSegmentIndex == 0 ? .monthly : .yearly,
            investmentYearsSelection: yearSelection(),
            customInvestmentYearsText: customYearsField.text ?? "",
            annualRateSelection: rateSelection(),
            customAnnualRateText: customRateField.text ?? ""
        )
    }

    private func yearSelection() -> InvestmentYearsSelection {
        let selectedIndex = yearsPresetControl.selectedSegmentIndex
        guard investmentYearOptions.indices.contains(selectedIndex) else {
            return .custom
        }

        return .preset(investmentYearOptions[selectedIndex].years)
    }

    private func yearSegmentIndex(for selection: InvestmentYearsSelection) -> Int {
        switch selection {
        case let .preset(years):
            investmentYearOptions.firstIndex { $0.years == years } ?? investmentYearOptions.count
        case .custom:
            investmentYearOptions.count
        }
    }

    private func rateSelection() -> AnnualRateSelection {
        let selectedIndex = ratePresetControl.selectedSegmentIndex
        guard annualRateOptions.indices.contains(selectedIndex) else {
            return .custom
        }

        return .preset(annualRateOptions[selectedIndex].rate)
    }

    private func segmentIndex(for selection: AnnualRateSelection) -> Int {
        switch selection {
        case let .preset(rate):
            annualRateOptions.firstIndex { $0.rate == rate } ?? annualRateOptions.count
        case .custom:
            annualRateOptions.count
        }
    }

    private func applyAnnualRateOptions(_ options: [AnnualRateOption]) {
        guard annualRateOptions != options else {
            return
        }

        annualRateOptions = options
        ratePresetControl.removeAllSegments()

        for (index, option) in options.enumerated() {
            ratePresetControl.insertSegment(withTitle: option.title, at: index, animated: false)
        }

        ratePresetControl.insertSegment(withTitle: localization.customTitle, at: options.count, animated: false)
    }

    private func applyInvestmentYearOptions(_ options: [InvestmentYearOption]) {
        guard investmentYearOptions != options else {
            return
        }

        investmentYearOptions = options
        yearsPresetControl.removeAllSegments()

        for (index, option) in options.enumerated() {
            yearsPresetControl.insertSegment(withTitle: option.title, at: index, animated: false)
        }

        yearsPresetControl.insertSegment(withTitle: localization.customTitle, at: options.count, animated: false)
    }

    private func setVisibility(of row: UIView, isVisible: Bool, animated: Bool) {
        let isCurrentlyVisible = !row.isHidden
        guard isVisible != isCurrentlyVisible else {
            row.alpha = isVisible ? 1 : 0
            row.transform = .identity
            return
        }

        if !isVisible {
            row.endEditing(true)
        }

        if animated {
            let animationOptions: UIView.AnimationOptions = [
                .curveEaseInOut,
                .beginFromCurrentState,
                .allowUserInteraction
            ]

            if isVisible {
                row.alpha = 0
                row.transform = CGAffineTransform(translationX: 0, y: -12)
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: animationOptions
                ) {
                    row.isHidden = false
                    row.alpha = 1
                    row.transform = .identity
                    self.superview?.layoutIfNeeded()
                    self.layoutIfNeeded()
                } completion: { _ in
                    row.transform = .identity
                }
            } else {
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: animationOptions
                ) {
                    row.alpha = 0
                    row.transform = CGAffineTransform(translationX: 0, y: -12)
                    row.isHidden = true
                    self.superview?.layoutIfNeeded()
                    self.layoutIfNeeded()
                } completion: { _ in
                    row.transform = .identity
                }
            }
        } else {
            row.isHidden = !isVisible
            row.alpha = isVisible ? 1 : 0
            row.transform = .identity
        }
    }
}
