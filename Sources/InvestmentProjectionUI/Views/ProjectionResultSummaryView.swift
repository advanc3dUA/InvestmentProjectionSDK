import UIKit

final class ProjectionResultSummaryView: UIStackView {
    private let theme: InvestmentProjectionTheme
    private let localization: ProjectionLocalization
    private let finalBalanceLabel = UILabel()
    private let totalContributionsLabel = UILabel()
    private let totalGrowthLabel = UILabel()
    private let chartView = ProjectionLineChartView()

    init(theme: InvestmentProjectionTheme, localization: ProjectionLocalization) {
        self.theme = theme
        self.localization = localization
        super.init(frame: .zero)
        configureView()
    }

    required init(coder: NSCoder) {
        self.theme = .default
        self.localization = ProjectionLocalization(locale: .current)
        super.init(coder: coder)
        configureView()
    }

    func apply(_ result: ProjectionResultViewState?) {
        guard let result else {
            isHidden = true
            return
        }

        isHidden = false
        finalBalanceLabel.text = result.finalBalanceText
        totalContributionsLabel.text = result.totalContributionsText
        totalGrowthLabel.text = result.totalGrowthText
        chartView.points = result.chartPoints
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

        finalBalanceLabel.font = .preferredFont(forTextStyle: .title1)
        finalBalanceLabel.adjustsFontForContentSizeCategory = true
        finalBalanceLabel.textColor = theme.primaryTextColor
        finalBalanceLabel.numberOfLines = 0

        chartView.theme = theme
        chartView.heightAnchor.constraint(equalToConstant: 180).isActive = true

        addArrangedSubview(makeCaptionLabel(localization.projectedValueTitle))
        addArrangedSubview(finalBalanceLabel)
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
}
