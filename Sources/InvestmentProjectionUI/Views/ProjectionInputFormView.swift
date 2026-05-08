import InvestmentProjectionCore
import UIKit

final class ProjectionInputFormView: UIStackView {
    var onChange: ((ProjectionFormInput) -> Void)?

    private let theme: InvestmentProjectionTheme
    private let localization: ProjectionLocalization
    private var annualRateOptions: [AnnualRateOption] = []
    private let balanceField = UITextField()
    private let contributionField = UITextField()
    private let yearsField = UITextField()
    private let customRateField = UITextField()
    private let validationLabel = UILabel()
    private let contributionFrequencyControl: UISegmentedControl
    private let ratePresetControl: UISegmentedControl
    private var isApplyingState = false

    init(theme: InvestmentProjectionTheme, localization: ProjectionLocalization) {
        self.theme = theme
        self.localization = localization
        self.contributionFrequencyControl = UISegmentedControl(items: [
            localization.monthlyTitle,
            localization.yearlyTitle
        ])
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
        self.ratePresetControl = UISegmentedControl()
        super.init(coder: coder)
        configureView()
    }

    func apply(_ state: InvestmentProjectionViewState) {
        isApplyingState = true
        defer { isApplyingState = false }

        let formInput = state.formInput
        applyAnnualRateOptions(state.annualRateOptions)
        balanceField.text = formInput.currentBalanceText
        contributionField.text = formInput.contributionAmountText
        contributionFrequencyControl.selectedSegmentIndex = formInput.contributionFrequency == .monthly ? 0 : 1
        yearsField.text = formInput.investmentYearsText
        ratePresetControl.selectedSegmentIndex = segmentIndex(for: formInput.annualRateSelection)
        customRateField.text = formInput.customAnnualRateText
        customRateField.isHidden = !state.isCustomRateVisible

        validationLabel.text = state.validationMessage
        validationLabel.isHidden = state.validationMessage == nil
    }

    private func configureView() {
        axis = .vertical
        spacing = 12
        layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        isLayoutMarginsRelativeArrangement = true
        backgroundColor = theme.surfaceColor
        layer.cornerRadius = theme.cornerRadius
        layer.borderColor = theme.borderColor.cgColor
        layer.borderWidth = 0.5

        addArrangedSubview(makeTextFieldRow(title: localization.currentBalanceTitle, textField: balanceField))
        addArrangedSubview(makeTextFieldRow(title: localization.contributionTitle, textField: contributionField))
        addArrangedSubview(makeControlRow(title: localization.frequencyTitle, control: contributionFrequencyControl))
        addArrangedSubview(makeTextFieldRow(title: localization.yearsTitle, textField: yearsField))
        addArrangedSubview(makeControlRow(title: localization.annualRateTitle, control: ratePresetControl))
        addArrangedSubview(makeTextFieldRow(title: localization.customRateTitle, textField: customRateField))
        addArrangedSubview(validationLabel)

        [balanceField, contributionField, customRateField].forEach {
            configureTextField($0, keyboardType: .decimalPad)
        }
        configureTextField(yearsField, keyboardType: .numberPad)

        [contributionFrequencyControl, ratePresetControl].forEach {
            $0.selectedSegmentTintColor = theme.accentColor
            $0.addTarget(self, action: #selector(inputDidChange), for: .valueChanged)
        }

        validationLabel.font = .preferredFont(forTextStyle: .footnote)
        validationLabel.textColor = .systemRed
        validationLabel.numberOfLines = 0
        validationLabel.isHidden = true
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
        stack.spacing = 6

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = theme.secondaryTextColor

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(arrangedView)
        return stack
    }

    private func configureTextField(_ textField: UITextField, keyboardType: UIKeyboardType) {
        textField.borderStyle = .roundedRect
        textField.keyboardType = keyboardType
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(inputDidChange), for: .editingChanged)
        textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
    }

    @objc private func inputDidChange() {
        guard !isApplyingState else {
            return
        }

        customRateField.isHidden = rateSelection() != .custom
        onChange?(currentFormInput())
    }

    private func currentFormInput() -> ProjectionFormInput {
        ProjectionFormInput(
            currentBalanceText: balanceField.text ?? "",
            contributionAmountText: contributionField.text ?? "",
            contributionFrequency: contributionFrequencyControl.selectedSegmentIndex == 0 ? .monthly : .yearly,
            investmentYearsText: yearsField.text ?? "",
            annualRateSelection: rateSelection(),
            customAnnualRateText: customRateField.text ?? ""
        )
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
}
