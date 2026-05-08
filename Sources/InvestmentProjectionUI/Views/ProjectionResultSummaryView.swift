import InvestmentProjectionCore
import UIKit

final class ProjectionResultSummaryView: UIStackView {
    private let theme: InvestmentProjectionTheme
    private let localization: ProjectionLocalization
    private let formatter: ProjectionValueFormatter
    private let finalBalanceLabel = UILabel()
    private let selectedYearLabel = UILabel()
    private let totalContributionsLabel = UILabel()
    private let totalGrowthLabel = UILabel()
    private let chartView = ProjectionLineChartView()
    private var currentResult: ProjectionResultViewState?

    init(theme: InvestmentProjectionTheme, localization: ProjectionLocalization) {
        self.theme = theme
        self.localization = localization
        self.formatter = ProjectionValueFormatter(
            locale: localization.locale,
            currencyCode: localization.currencyCode
        )
        super.init(frame: .zero)
        configureView()
    }

    required init(coder: NSCoder) {
        self.theme = .default
        self.localization = ProjectionLocalization(locale: .current)
        self.formatter = ProjectionValueFormatter(
            locale: self.localization.locale,
            currencyCode: self.localization.currencyCode
        )
        super.init(coder: coder)
        configureView()
    }

    func apply(_ result: ProjectionResultViewState?) {
        guard let result else {
            currentResult = nil
            isHidden = true
            return
        }

        currentResult = result
        isHidden = false
        displayFinalSummary(for: result)
        chartView.onSelectionChanged = { [weak self] point in
            self?.displaySummary(for: point)
        }
        chartView.onScrubbingEnded = { [weak self] in
            guard let self, let result = self.currentResult else {
                return
            }

            self.displayFinalSummary(for: result)
        }
        chartView.points = result.chartPoints
    }

    func updateAppearance() {
        backgroundColor = theme.surfaceColor
        layer.borderColor = theme.borderColor.cgColor
        finalBalanceLabel.textColor = theme.primaryTextColor
        selectedYearLabel.textColor = theme.secondaryTextColor
        totalContributionsLabel.textColor = theme.primaryTextColor
        totalGrowthLabel.textColor = theme.positiveColor
        chartView.theme = theme
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

        finalBalanceLabel.font = .preferredFont(forTextStyle: .title1)
        finalBalanceLabel.adjustsFontForContentSizeCategory = true
        finalBalanceLabel.textColor = theme.primaryTextColor
        finalBalanceLabel.numberOfLines = 0

        selectedYearLabel.font = .preferredFont(forTextStyle: .headline)
        selectedYearLabel.adjustsFontForContentSizeCategory = true
        selectedYearLabel.textColor = theme.secondaryTextColor

        chartView.theme = theme
        chartView.heightAnchor.constraint(equalToConstant: 180).isActive = true

        addArrangedSubview(makeCaptionLabel(localization.projectedValueTitle))
        addArrangedSubview(finalBalanceLabel)
        addArrangedSubview(selectedYearLabel)
        addArrangedSubview(chartView)
        addArrangedSubview(makeMetricRow(title: localization.contributedTitle, label: totalContributionsLabel))
        addArrangedSubview(makeMetricRow(title: localization.growthTitle, label: totalGrowthLabel, valueColor: theme.positiveColor))
    }

    private func makeMetricRow(
        title: String,
        label: UILabel,
        valueColor: UIColor? = nil
    ) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.distribution = .equalSpacing
        stack.spacing = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = theme.secondaryTextColor

        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = valueColor ?? theme.primaryTextColor
        label.textAlignment = .right

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(label)
        return stack
    }

    private func makeCaptionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = theme.secondaryTextColor
        return label
    }

    private func displayFinalSummary(for result: ProjectionResultViewState) {
        finalBalanceLabel.text = result.finalBalanceText
        selectedYearLabel.text = result.selectedYearText
        totalContributionsLabel.text = result.totalContributionsText
        totalGrowthLabel.text = result.totalGrowthText
    }

    private func displaySummary(for point: ProjectionYearPoint) {
        guard let result = currentResult else {
            return
        }

        finalBalanceLabel.text = formatter.currencyString(from: point.balance)
        selectedYearLabel.text = "\(result.baseCalendarYear + point.year)"
        totalContributionsLabel.text = formatter.currencyString(from: point.contributionsToDate)
        totalGrowthLabel.text = formatter.currencyString(from: point.growthToDate)
    }
}
